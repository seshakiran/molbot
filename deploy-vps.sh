#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   ClawdBot VPS Auto-Deployment Script   ${NC}"
echo -e "${GREEN}=========================================${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}Please run as root (use sudo).${NC}"
  exit 1
fi

# 1. Update System
echo -e "${GREEN}[1/7] Updating system packages...${NC}"
# Prevent interactive popups during apt upgrade
export DEBIAN_FRONTEND=noninteractive
apt update && apt upgrade -y
apt install -y curl git build-essential unzip

# 2. Install Node.js v23
echo -e "${GREEN}[2/7] Installing Node.js v23...${NC}"
if ! command -v node &> /dev/null || [[ $(node -v) != v23* ]]; then
    curl -fsSL https://deb.nodesource.com/setup_23.x | bash -
    apt install -y nodejs
else
    echo "Node.js v23 is already installed."
fi

# 3. Create clawdbot user
echo -e "${GREEN}[3/7] Setting up 'clawdbot' user...${NC}"
if id "clawdbot" &>/dev/null; then
    echo "User 'clawdbot' already exists."
else
    adduser --gecos "" --disabled-password clawdbot
    usermod -aG sudo clawdbot
    # Allow clawdbot to sudo without password (optional, useful for automation)
    echo "clawdbot ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/clawdbot
fi

# 4. Switch context to 'clawdbot' user for application installs
echo -e "${GREEN}[4/7] Switching to 'clawdbot' user for remaining steps...${NC}"

# Pass the script logic to run as clawdbot user
sudo -u clawdbot bash << 'EOF'
set -e
GREEN='\033[0;32m'
NC='\033[0m'

cd /home/clawdbot

# 5. Install Homebrew
echo -e "${GREEN}[5/7] Checking Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    # Homebrew install script
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configure shell environment
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed."
    # Ensure it's in the path for this session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 6. Install Bun (Required for 'bird' skill)
echo -e "${GREEN}[6/7] Checking Bun...${NC}"
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
    
    # Configure shell environment
    echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
else
    echo "Bun is already installed."
fi

# 7. Install ClawdBot
echo -e "${GREEN}[7/7] Installing ClawdBot globally...${NC}"
npm install -g clawdbot

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}      Deployment Complete! 🚀            ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Next Steps:"
echo "1. Switch to the user:  su - clawdbot"
echo "2. Run onboarding:      clawdbot onboard"
echo "3. Install Bird skill:  clawdbot skills install bird"
echo ""
EOF
