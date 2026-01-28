#!/bin/bash
set -e

# Configuration
CONFIG_DIR="$HOME/.config/bird"
CONFIG_FILE="$CONFIG_DIR/config.json5"

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Credentials (PASTE YOUR VALUES HERE)
AUTH_TOKEN="3f92d6f5d3b32e08ecfad66d702e403959287ff8"
CT0="9022f2d565a6e39079dd2f2199395d34ad222d1040c6a0dd5fe932e85835d35aa25646ce4034a39dd6906e5b09cbbf7e50e5ad7d87bd52b696f75de2ad0ac164b914281085c119dedde52241ab604e84"

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

# Export for current session (so the check works immediately)
export AUTH_TOKEN="$AUTH_TOKEN"
export CT0="$CT0"

# Add to .bashrc for persistence
if ! grep -q "AUTH_TOKEN" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Bird CLI Credentials" >> "$HOME/.bashrc"
    echo "export AUTH_TOKEN=\"$AUTH_TOKEN\"" >> "$HOME/.bashrc"
    echo "export CT0=\"$CT0\"" >> "$HOME/.bashrc"
    echo -e "${GREEN}✅ Credentials added to ~/.bashrc${NC}"
else
    echo "Credentials already present in .bashrc (skipping append)."
fi

# Create directory (still useful for other config)
mkdir -p "$CONFIG_DIR"

# Write config file (for settings only, not creds)
cat > "$CONFIG_FILE" <<EOF
{
  // Default configuration
  "timeoutMs": 10000,
  "quoteDepth": 1
}
EOF

echo -e "${GREEN}✅ Settings saved to: $CONFIG_FILE${NC}"
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
echo -e "${YELLOW}IMPORTANT: Run 'source ~/.bashrc' or restart your session to use 'bird' in the future.${NC}"
