# Sherpa ONNX Setup Guide for ClawdBot

This guide details how to manually set up **Sherpa ONNX** for offline Text-to-Speech (TTS) on a generic Linux VPS (x86_64).

## Prerequisites
- **Architecture:** x86_64 (Intel/AMD)
- **OS:** Ubuntu 22.04+ (Recommended)
- **Dependencies:** `curl`, `tar`, `bzip2`

## 1. Directory Structure
ClawdBot expects binaries and models in specific locations.

```bash
mkdir -p ~/.clawdbot/bin
mkdir -p ~/.clawdbot/models/sherpa-onnx
```

## 2. Install Binaries
We use the **static** Linux binaries to avoid dependency hell (GLIBC errors).

**Download:**
```bash
# Version 1.10.30 (Verified working)
wget https://github.com/k2-fsa/sherpa-onnx/releases/download/v1.10.30/sherpa-onnx-v1.10.30-linux-x64-static.tar.bz2
tar -xjf sherpa-onnx-v1.10.30-linux-x64-static.tar.bz2
```

**Install:**
Move the binary to the bin folder. Important: Create a symlink for compatibility.
```bash
cd sherpa-onnx-v1.10.30-linux-x64-static/bin
cp sherpa-onnx-offline-tts ~/.clawdbot/bin/
ln -sf ~/.clawdbot/bin/sherpa-onnx-offline-tts ~/.clawdbot/bin/sherpa-onnx-tts
```
*Note: The skill expects `sherpa-onnx-tts`, but the release provides `sherpa-onnx-offline-tts`.*

## 3. Install Voice Model
We use the `vits-piper-en_US-amy-low` model (High quality, low resource usage).

```bash
cd ~/.clawdbot/models/sherpa-onnx
wget https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-en_US-amy-low.tar.bz2
tar -xjf vits-piper-en_US-amy-low.tar.bz2
```

## 4. Environment Variables
ClawdBot needs to know where to find these files. Add this to your `~/.bashrc`:

```bash
export SHERPA_ONNX_RUNTIME_DIR="$HOME/.clawdbot/bin"
export SHERPA_ONNX_MODEL_DIR="$HOME/.clawdbot/models/sherpa-onnx/vits-piper-en_US-amy-low"
```

Apply changes:
```bash
source ~/.bashrc
```

## 5. Verification
Test the text-to-speech manually:

```bash
~/.clawdbot/bin/sherpa-onnx-tts \
  --vits-model="$SHERPA_ONNX_MODEL_DIR/en_US-amy-low.onnx" \
  --vits-tokens="$SHERPA_ONNX_MODEL_DIR/tokens.txt" \
  --vits-data-dir="$SHERPA_ONNX_MODEL_DIR/espeak-ng-data" \
  --output-filename="test.wav" \
  "Hello, verifying Sherpa setup."
```

If this generates a `test.wav` file without errors, the setup is complete.
