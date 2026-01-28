#!/bin/bash
set -e

# Configuration
CONFIG_DIR="$HOME/.config/bird"
CONFIG_FILE="$CONFIG_DIR/config.json5"

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Credentials (PASTE YOUR VALUES HERE)
AUTH_TOKEN="YOUR_AUTH_TOKEN_HERE"
CT0="YOUR_CT0_HERE"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}      Bird CLI Configuration Setup       ${NC}"
echo -e "${GREEN}=========================================${NC}"

echo "Configuring bird with provided credentials..."
echo ""

# Validate that user updated the script
if [[ "$AUTH_TOKEN" == "YOUR_AUTH_TOKEN_HERE" ]]; then
    echo -e "${RED}ERROR: You must edit this script and paste your auth_token and ct0 first!${NC}"
    exit 1
fi

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
