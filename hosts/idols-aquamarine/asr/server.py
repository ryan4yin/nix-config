"""OpenAI-compatible speech-to-text served by OpenVINO GenAI on the Intel NPU.

vinput records raw PCM (S16_LE, mono, 16 kHz), wraps it in a WAV container and
POSTs it to /v1/audio/transcriptions; this service is that endpoint. Whisper is
the only ASR family OpenVINO publishes fully static IRs for, and a static graph
is what the NPU compiler accepts -- every other family keeps a dynamic time axis
and aborts the compiler, see WORKAROUNDS.md WA-037.
"""

import io
import logging
import os
import threading
import wave
from contextlib import asynccontextmanager

import numpy as np
import openvino_genai
import uvicorn
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.concurrency import run_in_threadpool
from fastapi.responses import JSONResponse, PlainTextResponse

MODEL_DIR = os.environ["WHISPER_MODEL_DIR"]
MODEL_NAME = os.environ.get("WHISPER_MODEL_NAME", "whisper-large-v3-turbo")
DEVICE = os.environ.get("WHISPER_DEVICE", "NPU")
# Empty auto-detects the language per request; set it to pin one language.
DEFAULT_LANGUAGE = os.environ.get("WHISPER_LANGUAGE") or ""
CACHE_DIR = os.environ.get("OV_CACHE_DIR", "")
LISTEN_HOST = os.environ.get("WHISPER_HOST", "127.0.0.1")
LISTEN_PORT = int(os.environ.get("WHISPER_PORT", "18080"))
SAMPLE_RATE = 16000
MAX_AUDIO_SECONDS = int(os.environ.get("WHISPER_MAX_AUDIO_SECONDS") or "120")

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("whisper-asr")

# The idle pipeline, used by the next request. An auto-detected request leaves
# it dirty and prewarm() replaces it, so at most one instance is alive at rest.
pipeline = None
loaded = False
load_error = None
# One NPU: compile and infer one request at a time instead of contending for it.
infer_lock = threading.Lock()
slot_lock = threading.Lock()
build_lock = threading.Lock()


def build_pipeline() -> openvino_genai.WhisperPipeline:
    properties = {"CACHE_DIR": CACHE_DIR} if CACHE_DIR else {}
    return openvino_genai.WhisperPipeline(MODEL_DIR, DEVICE, **properties)


def prewarm() -> None:
    """Build the idle pipeline the next auto-detected request will use.

    Takes ~2 s with a warm NPU cache and runs while the user is not talking."""
    global pipeline
    if not build_lock.acquire(blocking=False):
        return
    try:
        with slot_lock:
            if pipeline is not None:
                return
        with infer_lock:
            fresh = build_pipeline()
        with slot_lock:
            if pipeline is None:
                pipeline = fresh
    except Exception:  # the next request falls back to building it inline
        log.exception("could not prewarm a pipeline")
    finally:
        build_lock.release()


def take_pipeline() -> openvino_genai.WhisperPipeline | None:
    global pipeline
    with slot_lock:
        idle, pipeline = pipeline, None
    return idle


def put_pipeline(idle: openvino_genai.WhisperPipeline) -> None:
    global pipeline
    with slot_lock:
        pipeline = idle


def load_pipeline() -> None:
    """Compile the model. The NPU takes ~70 s on a cold cache, so this runs in
    the background and /healthz reports readiness instead of blocking startup."""
    global pipeline, loaded, load_error
    log.info("loading %s on %s", MODEL_DIR, DEVICE)
    try:
        fresh = build_pipeline()
    except Exception as exc:  # reported through /healthz, not just the journal
        load_error = f"{type(exc).__name__}: {exc}"
        log.exception("model failed to load")
        return
    with slot_lock:
        pipeline = fresh
    loaded = True
    log.info("model loaded")


@asynccontextmanager
async def lifespan(_app: FastAPI):
    threading.Thread(target=load_pipeline, daemon=True).start()
    yield


app = FastAPI(lifespan=lifespan)


def pcm_from_wav(data: bytes) -> np.ndarray:
    with wave.open(io.BytesIO(data)) as wav:
        channels, width, rate = wav.getnchannels(), wav.getsampwidth(), wav.getframerate()
        if (channels, width, rate) != (1, 2, SAMPLE_RATE):
            raise ValueError(
                f"expected mono 16-bit 16 kHz, got {channels}ch/{width * 8}bit/{rate}Hz"
            )
        frames = wav.readframes(wav.getnframes())
    return np.frombuffer(frames, dtype=np.int16).astype(np.float32) / 32768.0


def transcribe(samples: np.ndarray, language: str) -> str:
    language = language or DEFAULT_LANGUAGE
    with infer_lock:
        idle = take_pipeline()
        if idle is None:
            # A previous request took it and the rebuild has not finished yet.
            idle = build_pipeline()
        if language:
            # Start from the pipeline's config: a fresh WhisperGenerationConfig()
            # has none of the tokenizer ids and raises "vector::reserve" inside
            # generate(); an unset task translates everything into English.
            config = idle.get_generation_config()
            config.task = "transcribe"
            config.language = f"<|{language}|>"
            text = idle.generate(samples, config).texts[0].strip()
            # A pinned language never relies on detection, so the pipeline is
            # still good for the next request.
            put_pipeline(idle)
            return text
        # On the NPU the language detected for one request carries over to the
        # next, so a pipeline that has already transcribed answers a request in
        # another language with a translation. This one is stale now.
        text = idle.generate(samples).texts[0].strip()
    # Building a pipeline keeps the GIL for ~2 s and would delay the response
    # that is already computed, so let it leave first and rebuild after.
    timer = threading.Timer(0.5, prewarm)
    timer.daemon = True
    timer.start()
    return text


@app.get("/healthz")
def healthz():
    if loaded:
        return {"status": "ok"}
    if load_error is not None:
        return JSONResponse({"status": "error", "detail": load_error}, status_code=503)
    return {"status": "loading"}


@app.get("/v1/models")
def list_models():
    return {"object": "list", "data": [{"id": MODEL_NAME, "object": "model", "owned_by": "local"}]}


@app.post("/v1/audio/transcriptions")
async def transcriptions(
    file: UploadFile = File(...),
    model: str = Form(""),
    language: str = Form(""),
    response_format: str = Form("json"),
):
    if not loaded:
        raise HTTPException(status_code=503, detail=load_error or "model is still loading")
    try:
        samples = pcm_from_wav(await file.read())
    except (wave.Error, ValueError, EOFError) as exc:
        raise HTTPException(status_code=400, detail=f"unsupported audio: {exc}") from exc
    if not samples.size:
        raise HTTPException(status_code=400, detail="empty audio")
    if samples.size > MAX_AUDIO_SECONDS * SAMPLE_RATE:
        raise HTTPException(status_code=400, detail=f"audio longer than {MAX_AUDIO_SECONDS} s")
    log.info("transcribing %.1f s of audio", samples.size / SAMPLE_RATE)
    try:
        text = await run_in_threadpool(transcribe, samples, language)
    except Exception as exc:
        log.exception("transcription failed")
        raise HTTPException(status_code=500, detail=f"transcription failed: {exc}") from exc
    if response_format == "text":
        return PlainTextResponse(text)
    return {"text": text}


if __name__ == "__main__":
    uvicorn.run(app, host=LISTEN_HOST, port=LISTEN_PORT, log_level="info")
