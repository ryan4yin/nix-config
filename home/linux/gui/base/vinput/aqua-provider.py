"""vinput ASR provider: send recorded PCM to the aquamarine Whisper service.

vinput pipes raw PCM (S16_LE, mono, 16 kHz) to stdin and reads the transcript
from stdout. The service speaks the OpenAI transcription API, so the PCM is
wrapped in a WAV container and POSTed as multipart.
"""

import io
import json
import os
import sys
import uuid
import wave
from urllib.error import URLError
from urllib.request import Request, urlopen

URL = os.environ["VINPUT_ASR_URL"]
TIMEOUT = float(os.environ.get("VINPUT_ASR_TIMEOUT", "60"))
SAMPLE_RATE = 16000


def as_wav(pcm: bytes) -> bytes:
    buffer = io.BytesIO()
    with wave.open(buffer, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(pcm)
    return buffer.getvalue()


def multipart(wav: bytes) -> tuple[bytes, str]:
    boundary = f"----vinput{uuid.uuid4().hex}"
    body = bytearray()
    body += f"--{boundary}\r\n".encode()
    body += b'Content-Disposition: form-data; name="file"; filename="audio.wav"\r\n'
    body += b"Content-Type: audio/wav\r\n\r\n"
    body += wav
    body += b"\r\n"
    body += f"--{boundary}\r\n".encode()
    body += b'Content-Disposition: form-data; name="model"\r\n\r\n'
    body += b"whisper-large-v3-turbo\r\n"
    body += f"--{boundary}--\r\n".encode()
    return bytes(body), f"multipart/form-data; boundary={boundary}"


def main() -> int:
    pcm = sys.stdin.buffer.read()
    if not pcm:
        print("no audio on stdin", file=sys.stderr)
        return 1
    payload, content_type = multipart(as_wav(pcm))
    request = Request(URL, data=payload, headers={"Content-Type": content_type}, method="POST")
    try:
        with urlopen(request, timeout=TIMEOUT) as response:
            transcript = json.load(response)
    except (URLError, OSError, ValueError) as exc:
        print(f"transcription request failed: {exc}", file=sys.stderr)
        return 1
    print(transcript.get("text", "").strip())
    return 0


if __name__ == "__main__":
    sys.exit(main())
