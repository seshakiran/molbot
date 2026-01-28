#!/bin/bash
set -e

# Configuration
SHERPA_VERSION="1.10.30"
# NOTE: The release filename includes '-static' for Linux x64
SHERPA_RELEASE_URL="https://github.com/k2-fsa/sherpa-onnx/releases/download/v${SHERPA_VERSION}/sherpa-onnx-v${SHERPA_VERSION}-linux-x64-static.tar.bz2"
MODEL_NAME="vits-piper-en_US-amy-low"
MODEL_URL="https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/${MODEL_NAME}.tar.bz2"

INSTALL_DIR="$HOME/.clawdbot/bin"
MODEL_DIR="$HOME/.clawdbot/models/sherpa-onnx"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   ClawdBot Voice Capability Setup       ${NC}"
echo -e "${GREEN}=========================================${NC}"

# 1. Setup Directories
echo -e "${GREEN}[1/4] Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$MODEL_DIR"

# 2. Install Sherpa ONNX Binaries
echo -e "${GREEN}[2/4] Installing Sherpa ONNX binaries...${NC}"
if [ -f "$INSTALL_DIR/sherpa-onnx-offline-tts" ]; then
    echo "Sherpa ONNX binaries already installed."
else
    echo "Downloading from: $SHERPA_RELEASE_URL"
    curl -L -o /tmp/sherpa-onnx.tar.bz2 "$SHERPA_RELEASE_URL"
    tar -xjf /tmp/sherpa-onnx.tar.bz2 -C /tmp
    
    # Move binaries to install dir
    # The tarball likely extracts to a folder with '-static' in the name
    SOURCE_DIR="/tmp/sherpa-onnx-v${SHERPA_VERSION}-linux-x64-static/bin"
    
    cp "$SOURCE_DIR/sherpa-onnx-offline-tts" "$INSTALL_DIR/"
    cp "$SOURCE_DIR/sherpa-onnx-offline-dspt" "$INSTALL_DIR/" || true 
    
    # Create symlink for compatibility with Walkie-Talkie skill which expects 'sherpa-onnx-tts'
    ln -sf "$INSTALL_DIR/sherpa-onnx-offline-tts" "$INSTALL_DIR/sherpa-onnx-tts"
    
    # Cleanup
    rm -rf /tmp/sherpa-onnx*
    echo "Installed to $INSTALL_DIR"
fi

# 3. Install Voice Model
echo -e "${GREEN}[3/4] Installing Voice Model ($MODEL_NAME)...${NC}"
if [ -d "$MODEL_DIR/$MODEL_NAME" ]; then
    echo "Model already installed."
else
    echo "Downloading model..."
    curl -L -o /tmp/model.tar.bz2 "$MODEL_URL"
    tar -xjf /tmp/model.tar.bz2 -C "$MODEL_DIR"
    rm /tmp/model.tar.bz2
    echo "Model installed to $MODEL_DIR/$MODEL_NAME"
fi

# 4. Configure Environment
echo -e "${GREEN}[4/4] Configuring Environment...${NC}"

# Define the exports
EXPORT_RUNTIME="export SHERPA_ONNX_RUNTIME_DIR=\"$INSTALL_DIR\""
EXPORT_MODEL="export SHERPA_ONNX_MODEL_DIR=\"$MODEL_DIR/$MODEL_NAME\""

# Add to .bashrc if not present
if ! grep -q "SHERPA_ONNX_RUNTIME_DIR" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# ClawdBot Voice Config" >> "$HOME/.bashrc"
    echo "$EXPORT_RUNTIME" >> "$HOME/.bashrc"
    echo "$EXPORT_MODEL" >> "$HOME/.bashrc"
    echo "Added config to ~/.bashrc"
else
    echo "Config already present in ~/.bashrc"
fi

# 5. Check Whisper
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Checking OpenAI Whisper...${NC}"

if command -v whisper &> /dev/null; then
    echo -e "✅ Whisper CLI is installed: $(which whisper)"
else
    echo -e "${YELLOW}⚠️  Whisper CLI not found in PATH.${NC}"
    echo "Attempting to install via pip (recommended for VPS)..."
    
    if command -v pip3 &> /dev/null; then
        pip3 install -U openai-whisper
        echo -e "${GREEN}✅ Installed Whisper via pip.${NC}"
    else
        echo -e "${RED}❌ python3-pip is missing.${NC}"
        echo "Run: sudo apt install python3-pip && pip3 install -U openai-whisper"
    fi
fi

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}      Setup Complete! 🎙️                 ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "${YELLOW}IMPORTANT: Run 'source ~/.bashrc' or restart your session to apply changes.${NC}"
echo -e "Then reload the bot: 'clawdbot reload'"
