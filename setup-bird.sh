#!/bin/bash
set -e

# Configuration
CONFIG_DIR="$HOME/.config/bird"
CONFIG_FILE="$CONFIG_DIR/config.json5"

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}      Bird CLI Configuration Setup       ${NC}"
echo -e "${GREEN}=========================================${NC}"

echo "This script will save your Twitter credentials for the 'bird' tool."
echo "You need your 'auth_token' and 'ct0' cookies from your browser."
echo ""

# Prompt for credentials
read -sp "Enter your 'auth_token': " AUTH_TOKEN
echo ""
read -sp "Enter your 'ct0': " CT0
echo ""
echo ""

# Create directory
mkdir -p "$CONFIG_DIR"

# Write config file (JSON5 format)
cat > "$CONFIG_FILE" <<EOF
{
  // Twitter credentials
  "authToken": "$AUTH_TOKEN",
  "ct0": "$CT0",
  
  // Default configuration
  "timeoutMs": 10000,
  "quoteDepth": 1
}
EOF

# Set permissions (important for credentials!)
chmod 600 "$CONFIG_FILE"

echo -e "${GREEN}✅ Configuration saved to: $CONFIG_FILE${NC}"
echo ""
echo "Verifying connection..."
echo "Running: bird whoami"
echo "-----------------------------------------"

# Verify
if command -v bird &> /dev/null; then
  bird whoami
else
  echo "⚠️ 'bird' command not found. Please install the bird skill first."
fi

echo "-----------------------------------------"
