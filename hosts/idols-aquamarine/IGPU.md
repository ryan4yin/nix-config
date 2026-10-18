# The Intel iGPU on aquamarine

The Arrow Lake-S iGPU (i915) does this host's video work and can run OpenVINO models; the R9700s
stay on inference. [hardware-intel-igpu.nix](./hardware-intel-igpu.nix) installs the stack and the
`openvino-gpu` wrapper. Measured 2026-10-18, OpenVINO 2026.4.0 / openvino-genai 2026.4.0.0.

## Devices

`openvino-gpu` puts the OpenCL 3.0 loader (`ocl-icd`) ahead of ROCm's clr and pins the Intel ICD;
without it the GPU plugin fails to load and GPU is missing from the device list (WA-038). Use it for
every OpenVINO run:

```bash
openvino-gpu python -c 'import openvino as ov; c = ov.Core(); print(c.available_devices)'
# ['CPU', 'GPU', 'NPU']
openvino-gpu python -c 'import openvino as ov; print(ov.Core().get_property("GPU", "FULL_DEVICE_NAME"))'
# Intel(R) Graphics (iGPU)
```

VA-API uses `/dev/dri/renderD128`:

```bash
nix shell nixpkgs#libva-utils -c vainfo --display drm --device /dev/dri/renderD128
nix shell nixpkgs#ffmpeg -c ffmpeg -hwaccel vaapi -hwaccel_device /dev/dri/renderD128 \
  -i in.mkv -c:v hevc_vaapi -qp 26 out.mkv
```

## Running OpenVINO GenAI models

Models with static or bounded-dynamic shapes compile on `GPU`; unbounded dynamic shapes fail with
`dynamic shape without upper bound`. Inspect a model before choosing the device:

```bash
openvino-gpu python - /path/to/model.xml <<'PY'
import sys
import openvino as ov

for port in ov.Core().read_model(sys.argv[1]).inputs:
    print(port.get_any_name(), port.get_partial_shape())
PY
```

### Whisper needs a static encoder

The published `whisper-large-v3-turbo-int8-ov` IRs are fully dynamic. The NPU pipeline reshapes them
internally and the CPU path runs them as-is, but the GPU path cannot compile the encoder. Reshape it
once, with batch bounded `0..1` so OpenVINO GenAI's `{0, 128, 3000}` input reset still matches, then
run the normal pipeline:

```bash
# Store paths change on every rebuild, so read them from the running service.
MODEL=$(systemctl cat whisper-asr | sed -n 's/^Environment="WHISPER_MODEL_DIR=\([^"]*\)"/\1/p')
ENVPY=$(systemctl cat whisper-asr | sed -n 's/^ExecStart=\([^ ]*\).*/\1/p')
OUT=/tmp/whisper-static

rm -rf "$OUT" && mkdir -p "$OUT"
cp "$MODEL"/*.json "$OUT"/
for f in "$MODEL"/*.bin "$MODEL"/*.xml; do
  case "$(basename "$f")" in
    openvino_encoder_model.*) ;;
    *) ln -s "$f" "$OUT/$(basename "$f")" ;;
  esac
done

openvino-gpu "$ENVPY" - <<PY
import openvino as ov

# 128 mel bins for large-v3/turbo, 3000 frames = 30 s window, batch bound 0..1.
enc = ov.Core().read_model("$MODEL/openvino_encoder_model.xml")
enc.reshape({"input_features": ov.PartialShape([ov.Dimension(0, 1), 128, 3000])})
ov.save_model(enc, "$OUT/openvino_encoder_model.xml", compress_to_fp16=False)
PY
```

Transcribe (mono 16 kHz 16-bit WAV):

```bash
openvino-gpu "$ENVPY" - "$OUT" /tmp/jfk.wav en <<'PY'
import sys
import wave

import numpy as np
import openvino_genai

models, wav_path, language = sys.argv[1:4]
with wave.open(wav_path) as wav:
    samples = (
        np.frombuffer(wav.readframes(wav.getnframes()), dtype=np.int16).astype(np.float32)
        / 32768.0
    )
pipe = openvino_genai.WhisperPipeline(models, "GPU", CACHE_DIR="/tmp/whisper-gpu-cache")
config = pipe.get_generation_config()
config.task = "transcribe"
config.language = f"<|{language}|>"
print(pipe.generate(samples, config).texts[0].strip())
PY
```

## Timings and memory

Steady state, pinned language, 3-5 iterations after warmup. NPU through the `whisper-asr` service;
iGPU and CPU standalone. Audio: 11.0 s English, 5.6 s Chinese.

| Device | English            | Chinese | CPU-s/request | Memory in use        |
| ------ | ------------------ | ------- | ------------- | -------------------- |
| NPU    | 1.47 s (1.46-1.57) | 1.36 s  | 0.055 / 0.042 | ~2.2 GiB (resident)  |
| iGPU   | 1.49 s             | 1.41 s  | 0.23 / 0.14   | ~2.1 GiB (on demand) |
| CPU    | 1.23 s             | 1.18 s  | 9.35 / 8.99   | ~1.1 GiB (on demand) |

| Device | Cold compile / first use                                                            | Peak memory |
| ------ | ----------------------------------------------------------------------------------- | ----------- |
| NPU    | ~70 s VPUX compile on a cold `/var/cache/whisper-asr`; warm starts import the blobs | 6.2 GB      |
| iGPU   | load 2.2 s instead of 0.7 s warm; first inference 1.8 s instead of 1.5 s            | 2.65 GB     |
| CPU    | load 0.95 s; first inference 1.85 s instead of 1.23 s                               | ~2.0 GB     |

## Language switching

Pinned and auto-detect (no `language`) both work on the iGPU and CPU: alternating en/zh in one
process or service is correct, 1.44-1.79 s on iGPU, 1.20-1.34 s on CPU. On the NPU pinned works
(1.46/1.36 s); auto-detect works while the idle pipeline is fresh (>=4 s between requests), but an
auto request right after a pinned one inherited the pinned language and translated the English audio
to Chinese, correct again after the ~4 s rebuild. A pinned request during that rebuild took 5.25 s.
Pin the language per client before mixing modes.

## Cache

A `CACHE_DIR` written by a failed GPU compile produced repeated text; deleting it and recompiling
fixed the output. Wipe the cache after changing the model or after a failed attempt.

## Which device

- **Whisper/ASR: NPU.** Same latency as the iGPU, lowest CPU cost, leaves the iGPU free.
- **iGPU: OpenVINO models that compile on `GPU`, and ASR fallback.** It occupies the GPU for the
  whole request, so transcodes and the console wait.
- **CPU: emergency only.** Fastest single request, but it keeps ~7.5 cores busy.
