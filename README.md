# How to Run ClawdBot 24/7 on a VPS (Complete Guide)

A step-by-step guide to deploying ClawdBot on an Ubuntu VPS for always-on AI automation via WhatsApp. This guide covers everything from initial setup to troubleshooting common issues.

---

## Why Run ClawdBot on a VPS?

Running ClawdBot on your local machine means it stops when your computer sleeps or shuts down. A VPS (Virtual Private Server) keeps your bot running **24/7**, responding to WhatsApp messages even while you're offline.

**Recommended specs:**
- Ubuntu 22.04 or 24.04
- 2+ vCPU cores
- 4GB RAM minimum (8GB recommended for faster skill installs)
- 30GB+ disk space

I used [Hostinger VPS](https://www.hostinger.com/vps-hosting) (~$6-10/month), but any Ubuntu VPS provider works (DigitalOcean, Linode, Vultr, etc.).

---

## Step 1: Connect to Your VPS

```bash
ssh root@YOUR_VPS_IP
```

---

## Step 2: Update the System

```bash
apt update && apt upgrade -y
```

> ⚠️ **Common Issue: Nginx Configuration Error**
> 
> If you see an error like:
> ```
> nginx: [emerg] "server" directive is not allowed here
> dpkg: error processing package nginx-core
> ```
> 
> **Fix it by temporarily moving Nginx configs:**
> ```bash
> mkdir -p /tmp/nginx-sites-backup
> mv /etc/nginx/sites-enabled/* /tmp/nginx-sites-backup/
> dpkg --configure -a
> apt --fix-broken install -y
> ```

---

## Step 3: Install Prerequisites

```bash
apt install -y curl git build-essential
```

---

## Step 4: Install Node.js v23+

ClawdBot requires Node.js >= 22.12.0. The default Ubuntu repos have older versions, so we use NodeSource:

```bash
curl -fsSL https://deb.nodesource.com/setup_23.x | bash -
apt install -y nodejs
```

**Verify:**
```bash
node -v   # Should show v23.x.x
npm -v    # Should show 10.x.x
```

> ⚠️ **If you accidentally installed an older version:**
> ```bash
> apt remove -y nodejs
> curl -fsSL https://deb.nodesource.com/setup_23.x | bash -
> apt install -y nodejs
> ```

---

## Step 5: Create a Non-Root User

Homebrew (required for ClawdBot skills) refuses to run as root. Create a dedicated user:

```bash
adduser clawdbot
usermod -aG sudo clawdbot
su - clawdbot
```

From this point forward, **run all commands as the `clawdbot` user**.

---

## Step 6: Install Homebrew (Linuxbrew)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation completes:
```bash
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew --version
```

---

## Step 7: Install Bun (Optional but Recommended)

Some ClawdBot skills require Bun:

```bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
bun --version
```

---

## Step 8: Install ClawdBot

```bash
npm install -g clawdbot
```

---

## Step 9: Run Onboarding

```bash
clawdbot onboard
```

The onboarding wizard will guide you through:

1. **Security acknowledgment** — Read and accept
2. **Model provider** — Choose OpenAI and enter your API key
3. **WhatsApp linking** — Scan the QR code with your phone
4. **Skills installation** — Select the skills you want (this takes 5-15 minutes)
5. **Hooks configuration** — Enable recommended hooks
6. **Gateway setup** — Automatic systemd service installation

**Pro tip:** When asked about skills, you can skip and install specific ones later:
```bash
clawdbot skills install gemini
clawdbot skills install summarize
```

---

## Step 10: Access the Control UI

The ClawdBot Control UI binds to localhost (127.0.0.1) for security. To access it from your browser, use an **SSH tunnel**:

**On your local machine** (not the VPS):
```bash
ssh -L 18789:127.0.0.1:18789 YOUR_USER@YOUR_VPS_IP
```

Keep this terminal open, then visit:
```
http://127.0.0.1:18789/?token=YOUR_TOKEN
```

Get your token anytime with:
```bash
clawdbot dashboard --no-open
```


---

## Pro Tip: Create a Shortcut for Easier Access

Instead of typing the long SSH command every time, you can create a shortcut.

**Method 1: SSH Config (Recommended)**
Add this to your local machine's `~/.ssh/config` file:

```text
Host clawdbot-ui
    HostName YOUR_VPS_IP
    User clawdbot
    LocalForward 18789 127.0.0.1:18789
```

Now you can just run: `ssh clawdbot-ui`.

**Method 2: Background Command**
Run this command to start the tunnel in the background so you can close the terminal:
```bash
ssh -f -N -L 18789:127.0.0.1:18789 clawdbot@YOUR_VPS_IP
```

---

## Useful Commands

| Command | Description |
|---------|-------------|
| `clawdbot tui` | Open terminal UI |
| `clawdbot status` | Check status |
| `clawdbot doctor` | Diagnose issues |
| `clawdbot skills list` | List installed skills |
| `clawdbot skills install NAME` | Install a specific skill |
| `systemctl --user status clawdbot-gateway` | Check gateway service |
| `systemctl --user restart clawdbot-gateway` | Restart gateway |

---

## FAQ / Troubleshooting

### Skills fail with "brew not installed"

```
◇ Install failed: gemini — brew not installed
```

**Fix:** Install Homebrew as a non-root user (Step 6).

---

### Skills fail with "spawn bun ENOENT"

```
◇ Install failed: bird — spawn bun ENOENT
```

**Fix:** Install Bun (Step 7).

---

### Skills fail with "Running Homebrew as root is extremely dangerous"

```
Error: Running Homebrew as root is extremely dangerous and no longer supported.
```

**Fix:** You're running as root. Switch to a non-root user (Step 5).

---

### Node version mismatch

```
npm warn EBADENGINE required: { node: '>=22.12.0' }, current: { node: 'v20.x.x' }
```

**Fix:** Install Node.js v23 via NodeSource (Step 4).

---

### Control UI not accessible

The gateway binds to localhost only. Use an SSH tunnel (Step 10).

**Verify the gateway is running:**
```bash
systemctl --user status clawdbot-gateway
ss -tlnp | grep 18789
```

---

### Control UI shows "gateway token mismatch"

If you see this error in the Control UI:
```
disconnected (1008): unauthorized: gateway token mismatch
```

**Fix:** You need the **tokenized URL**, not just `http://127.0.0.1:18789`.

Get your token:
```bash
clawdbot dashboard --no-open
```

Copy the full URL with the token:
```
http://127.0.0.1:18789/?token=YOUR_TOKEN_HERE
```

---

### OpenAI "organization must be verified" error

```
400 Your organization must be verified to generate reasoning summaries
```

**Cause:** OpenAI requires organization verification for certain models (like gpt-5.2 with reasoning).

**Fix options:**
1. **Wait 15-30 minutes** after completing verification at [platform.openai.com](https://platform.openai.com/settings/organization/general)
2. **Switch to a model that doesn't require verification:**
   ```bash
   clawdbot configure --section model
   ```
   Select `gpt-4o` instead of `gpt-5.2`

---

### Security Warnings: Group Policy & Password

If `clawdbot status` shows security warnings:

**1. "Open groupPolicy with elevated tools enabled"**
This means anyone in a WhatsApp group can trigger tools.
**Fix:** Edit `~/.clawdbot/agents/main/config.json`:
```json
"channels": {
  "whatsapp": {
    "groupPolicy": "allowlist"
  }
}
```

**2. "Gateway password is stored in config"**
Storing passwords in plain text is risky.
**Fix:** Move it to an environment variable:
1. Run `clawdbot configure --section gateway` and clear the password field.
2. Edit `~/.bashrc`:
   ```bash
   export CLAWDBOT_GATEWAY_PASSWORD="your-secure-password"
   ```
3. Reload: `source ~/.bashrc` and restart gateway.

---

### Skill installation is slow

First-time skill installation can take 10-20 minutes because Homebrew compiles dependencies. This is normal, especially on VPS with limited CPU.

**Speed it up:**
- Skip skills during onboarding, install only what you need later
- Upgrade to a VPS with more RAM/CPU

---

### Skills fail with "arm64 architecture required"

```
◇ Install failed: summarize — The arm64 architecture is required for this software.
◇ Install failed: openai-whisper — ...
```

**Cause:** Some skills are built specifically for **Apple Silicon (ARM64)** and won't run on Intel/AMD x86_64 VPS.

**Skills that work on x86_64 VPS:**
- ✅ `gemini` — Google AI integration
- ✅ `gog` — Google search
- ✅ `nano-banana-pro` — Document processing
- ✅ `nano-pdf` — PDF handling
- ✅ `obsidian` — Note integration
- ✅ `wacli` — WhatsApp CLI

**Skills that require ARM64 (won't work on most VPS):**
- ❌ `summarize`
- ❌ `openai-whisper` (audio transcription)
- ❌ Some macOS-specific skills

This is expected behavior — just skip these skills during onboarding.

---

### How do I message my bot?

You can't message yourself on WhatsApp. Have someone else message your linked WhatsApp number, or use:
- The TUI: `clawdbot tui`
- The Control UI via SSH tunnel

---

## Recommended VPS Specs

| Use Case | RAM | Notes |
|----------|-----|-------|
| Basic (WhatsApp + few skills) | 4GB | Works fine, slow skill installs |
| Standard (multiple skills) | 8GB | Recommended for daily use |
| Heavy (whisper, media processing) | 16GB | For audio transcription, etc. |

---

## Post-Setup: Security Fixes

After onboarding, run `clawdbot status` and fix any security warnings:

```bash
# Fix critical: credentials directory permissions
chmod 700 ~/.clawdbot/credentials

# Fix warn: state directory permissions  
chmod 700 ~/.clawdbot
```

---

## Post-Setup: Verification

```bash
# Check gateway is running
ss -tlnp | grep 18789

# Check full status
clawdbot status

# Get dashboard link with token
clawdbot dashboard --no-open
```

**Expected status output:**
```
Gateway service │ systemd installed · enabled · running
WhatsApp        │ ON │ OK │ linked
```

---

## Troubleshooting: DBUS Session Error

If you see this when using `systemctl --user`:
```
Failed to connect to bus: $DBUS_SESSION_BUS_ADDRESS and $XDG_RUNTIME_DIR not defined
```

**Fix Option 1:** Set environment variables
```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
```

**Fix Option 2:** SSH directly as the clawdbot user instead of using `su`
```bash
ssh clawdbot@YOUR_VPS_IP
```

**Fix Option 3:** Start gateway without systemd
```bash
clawdbot gateway
```

---

## Upgrading Your VPS

If you upgrade your VPS (e.g., 4GB → 8GB RAM):

- ✅ **No reinstallation needed** — all data preserved
- ✅ ClawdBot, Homebrew, Node.js remain installed
- ✅ WhatsApp stays linked
- ⚠️ Brief downtime during upgrade (few minutes)

**After upgrade, verify:**
```bash
ssh clawdbot@YOUR_VPS_IP
clawdbot status
```

The gateway should auto-start via systemd.

---

## Conclusion

Once onboarding completes, ClawdBot runs 24/7 via systemd. You can close your SSH session and the bot will keep responding to WhatsApp messages.

**Quick reference:**
| Task | Command |
|------|---------|
| Start TUI | `clawdbot tui` |
| Check status | `clawdbot status` |
| View logs | `clawdbot logs --follow` |
| Get dashboard URL | `clawdbot dashboard --no-open` |
| Restart gateway | `clawdbot gateway stop && clawdbot gateway` |

**Next steps:**
- Explore [ClawdBot documentation](https://docs.clawd.bot/)
- Check out [what people are building](https://clawd.bot/showcase)
- Configure web search with a [Brave API key](https://brave.com/search/api/)

Happy automating! 🦞
