# ClawdBot VPS Setup & Troubleshooting Log

This document records the steps taken to deploy ClawdBot on a VPS, detailing the specific failures encountered and the mitigation strategies applied.

## 1. Initial Deployment
**Goal:** Deploy ClawdBot and dependencies on a fresh Ubuntu VPS.

### Action
Created `deploy-vps.sh` to automate:
- System updates (`apt update && upgrade`)
- Node.js v23 installation (via NodeSource)
- `clawdbot` user creation
- Homebrew installation (as non-root user)
- Bun installation (required for Bird skill)

---

## 2. Voice Capability Setup (Walkie-Talkie Mode)
**Goal:** Enable local text-to-speech (Sherpa ONNX) and speech-to-text (Whisper).

### Failure 1: Incorrect Sherpa Download URL
- **Error:** `tar: Error is not recoverable: exiting now` (Download was 404/invalid)
- **Cause:** The initial script used a generic URL. The correct Linux x64 binary includes a `-static` suffix in the filename.
- **Fix:** Updated `setup-voice.sh` to point to `sherpa-onnx-v1.10.30-linux-x64-static.tar.bz2`.

### Failure 2: Binary Name Mismatch
- **Error:** The "Walkie-Talkie" skill expects a binary named `sherpa-onnx-tts`.
- **Cause:** The official release extracts a binary named `sherpa-onnx-offline-tts`.
- **Fix:** Added a symlink step in `setup-voice.sh`:
  ```bash
  ln -sf .../sherpa-onnx-offline-tts .../sherpa-onnx-tts
  ```

### Failure 3: Missing Env Vars
- **Error:** Skill flagged missing `SHERPA_ONNX_RUNTIME_DIR`.
- **Fix:** Script now exports these to `~/.bashrc`:
  ```bash
  export SHERPA_ONNX_RUNTIME_DIR="$HOME/.clawdbot/bin"
  export SHERPA_ONNX_MODEL_DIR="$HOME/.clawdbot/models/sherpa-onnx/vits-piper-en_US-amy-low"
  ```

---

## 3. Bird CLI Configuration (Twitter/X)
**Goal:** Authenticate the `bird` CLI tool using browser cookies.

### Failure 1: Config File Ignored
- **Error:** `bird whoami` failed with `❌ Missing required credentials` even after `config.json5` was created.
- **Cause:** The `bird` tool (version 0.8.0) does not read credentials (`authToken`, `ct0`) from the config file; it requires them as environment variables or direct flags.
- **Fix:** Updated `setup-bird.sh` to export variables to `.bashrc` instead of writing them to the JSON config.
  ```bash
  echo "export AUTH_TOKEN=\"...\"" >> ~/.bashrc
  echo "export CT0=\"...\"" >> ~/.bashrc
  ```

---

## 4. System Stability (Resource Exhaustion)
**Goal:** Ensure the VPS remains stable under load.

### Failure: "Too many open files"
- **Error:** SSH connection refused with `accept: Too many open files`.
- **Cause:** The default Linux file descriptor limit (`ulimit -n`) is often **1024**. ClawdBot (Node.js) + Browser automation + WhatsApp + heavy threading usage exhausted this limit.
- **Fix:** Created `fix-limits.sh` to permanently increase the limit to **65536**.
  1. Updated `/etc/security/limits.d/clawdbot.conf`.
  2. Updated `/etc/systemd/user.conf` (`DefaultLimitNOFILE=65536`).
  3. **Mitigation:** Reboot required to apply changes to all services.

---

## Summary of Helper Scripts
All scripts are now in the repository:

1.  **`deploy-vps.sh`**: Initial system bootstrap.
2.  **`setup-voice.sh`**: Downloads voice models, binaries, and fixes compatibility links.
3.  **`setup-bird.sh`**: Interactively (or via edit) configures Twitter credentials.
4.  **`fix-limits.sh`**: Increases system stability by raising `ulimit`.

### Recommended Post-Install Checks
After running all scripts and rebooting:
```bash
ulimit -n          # Should be 65536
bird whoami        # Should show your Twitter handle
clawdbot status    # Should show all systems GO
```
