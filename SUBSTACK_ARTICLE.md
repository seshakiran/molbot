# Update: Simplify Your Life with SSH Shortcuts

If you are tired of typing that long SSH command every time you want to check your ClawdBot dashboard, here is a quick tip to make your life easier.

## The Problem
Accessing the dashboard requires an SSH tunnel:
`ssh -L 18789:127.0.0.1:18789 clawdbot@YOUR_VPS_IP`

Closing the terminal kills the connection, which is annoying.

## The Solution

### Option 1: The "Set and Forget" Background Command
Run this to send the tunnel to the background right away:
```bash
ssh -f -N -L 18789:127.0.0.1:18789 clawdbot@YOUR_VPS_IP
```
Now you can close the terminal window, and the tunnel keeps running!

### Option 2: The Permanent Shortcut (Best)
Add this to your `~/.ssh/config` file on your Mac/PC:

```text
Host clawdbot-ui
    HostName YOUR_VPS_IP
    User clawdbot
    LocalForward 18789 127.0.0.1:18789
```

Now, whenever you want to connect, just type:
**`ssh clawdbot-ui`**

Simple, fast, and efficient. Happy automating! 🦞
