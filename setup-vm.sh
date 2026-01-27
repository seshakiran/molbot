#!/bin/bash
set -e

# Configuration
VM_NAME="clawdbot-vm"
IMAGE_NAME="ubuntu-noble-vanilla:latest"
CPU_COUNT=4
MEMORY_SIZE="4GB"
DISK_SIZE="32GB"

# Check dependencies
if ! command -v lume &> /dev/null; then
    echo "Lume is not installed. Installing via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "❌ Error: Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
    brew tap trycua/lume
    brew install lume
else
    echo "✅ Lume is already installed."
fi

# Cleanup ANY broken/existing VM first (to start fresh)
echo "Removing any existing/broken VM named '$VM_NAME'..."
lume delete "$VM_NAME" 2>/dev/null || true

echo "Creating Ubuntu VM from image: $IMAGE_NAME"

# Pull and Run the specific Ubuntu image
# Using 'lume run' directly with the image name creates and runs it
lume run "$IMAGE_NAME" \
  --name "$VM_NAME" \
  --cpu "$CPU_COUNT" \
  --memory "$MEMORY_SIZE" \
  --disk-size "$DISK_SIZE" \
  > /dev/null 2>&1 &

echo "✅ VM process started in background."
echo "Waiting 20 seconds for VM to pull image, boot and network..."
sleep 20

# Get connection info
echo "---------------------------------------------------"
echo "VM Status:"
lume ls
echo "---------------------------------------------------"
echo "To connect, first get the IP address:"
echo "lume get $VM_NAME"
echo ""
echo "Then connect via SSH (password 'ubuntu' or 'lume'):"
echo "ssh ubuntu@<IP_ADDRESS>"
echo "---------------------------------------------------"
