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
from fastapi.responses import JSONResponse, PlainTextResponse

MODEL_DIR = os.environ["WHISPER_MODEL_DIR"]
MODEL_NAME = os.environ.get("WHISPER_MODEL_NAME", "whisper-large-v3-turbo")
DEVICE = os.environ.get("WHISPER_DEVICE", "NPU")
CACHE_DIR = os.environ.get("OV_CACHE_DIR", "")
LISTEN_HOST = os.environ.get("WHISPER_HOST", "127.0.0.1")
LISTEN_PORT = int(os.environ.get("WHISPER_PORT", "18080"))
SAMPLE_RATE = 16000

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("whisper-asr")

pipeline = None
load_error = None
# One NPU: compile and infer one request at a time instead of contending for it.
infer_lock = threading.Lock()


def load_pipeline() -> None:
    """Compile the model. The NPU takes ~70 s on a cold cache, so this runs in
    the background and /healthz reports readiness instead of blocking startup."""
    global pipeline, load_error
    log.info("loading %s on %s", MODEL_DIR, DEVICE)
    try:
        properties = {"CACHE_DIR": CACHE_DIR} if CACHE_DIR else {}
        pipeline = openvino_genai.WhisperPipeline(MODEL_DIR, DEVICE, **properties)
    except Exception as exc:  # reported through /healthz, not just the journal
        load_error = f"{type(exc).__name__}: {exc}"
        log.exception("model failed to load")
        return
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
            raise ValueError(f"expected mono 16-bit 16 kHz, got {channels}ch/{width * 8}bit/{rate}Hz")
        frames = wav.readframes(wav.getnframes())
    return np.frombuffer(frames, dtype=np.int16).astype(np.float32) / 32768.0


def transcribe(samples: np.ndarray, language: str) -> str:
    config = None
    if language:
        config = openvino_genai.WhisperGenerationConfig()
        config.language = f"<|{language}|>"
    with infer_lock:
        result = pipeline.generate(samples, config) if config else pipeline.generate(samples)
    return result.texts[0].strip()


@app.get("/healthz")
def healthz():
    if pipeline is not None:
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
    if pipeline is None:
        raise HTTPException(status_code=503, detail=load_error or "model is still loading")
    try:
        samples = pcm_from_wav(await file.read())
    except (wave.Error, ValueError, EOFError) as exc:
        raise HTTPException(status_code=400, detail=f"unsupported audio: {exc}") from exc
    if not samples.size:
        raise HTTPException(status_code=400, detail="empty audio")
    log.info("transcribing %.1f s of audio", samples.size / SAMPLE_RATE)
    text = transcribe(samples, language)
    if response_format == "text":
        return PlainTextResponse(text)
    return {"text": text}


if __name__ == "__main__":
    uvicorn.run(app, host=LISTEN_HOST, port=LISTEN_PORT, log_level="info")
