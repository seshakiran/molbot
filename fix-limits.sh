#!/bin/bash
set -e

# Needs root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo ./fix-limits.sh)"
  exit 1
fi

USER="clawdbot"
LIMIT_CONF="/etc/security/limits.d/clawdbot.conf"

echo "Increasing file limits for user: $USER"

# 1. Update system limits
echo "Writing $LIMIT_CONF..."
cat > "$LIMIT_CONF" <<EOF
$USER soft nofile 65536
$USER hard nofile 65536
EOF

# 2. Update systemd user configuration
# Systemd user instances don't always respect limits.conf, so we edit user.conf
echo "Updating /etc/systemd/user.conf..."
if ! grep -q "DefaultLimitNOFILE=65536" /etc/systemd/user.conf; then
    echo "DefaultLimitNOFILE=65536" >> /etc/systemd/user.conf
fi

echo "✅ Limits updated."
echo "You must REBOOT the VPS for these changes to take full effect for all services."
echo ""
echo "Command to reboot: reboot"
