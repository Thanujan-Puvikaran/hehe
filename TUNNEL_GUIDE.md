# Tunnel Guide

## Quick Start

### Restart Tunnel with New URL
```bash
make tunnel-restart
```
This command:
- Kills any existing tunnel process
- Starts a fresh Cloudflare tunnel
- Generates a new URL
- Sends the URL to your phone via iMessage

## Available Commands

### Tunnel Management
```bash
make tunnel-restart           # Kill + restart tunnel with fresh URL + iMessage
make kill-tunnel             # Kill tunnel process (no restart)
make tunnel-bg-log           # Start tunnel in background with logs + iMessage
make tunnel-log              # View live tunnel logs (requires tunnel running)
```

### Server Management
```bash
make server                  # Start server on http://localhost:8888
make kill-server             # Kill server process
```

### Status & Testing
```bash
make status                  # Check server health
make ps                      # Show running tunnel/server processes
make tunnel-imessage-test    # Send a test iMessage
```

### Utility
```bash
make help                    # Show all available commands
make clean                   # Remove cache and logs
```

## Manual Commands

### Kill Tunnel Only
```bash
pkill -f 'cloudflared tunnel'
```

### Restart Server with Environment Variables
```bash
cd /Users/thanujanpuvikaran/Documents/repositories/hehe && \
set -a && source .env && set +a && \
python3 server.py
```

### View Tunnel Logs
```bash
tail -f /tmp/cloudflare-tunnel.log
```

### View Restart Logs (with URL & iMessage status)
```bash
tail -f /tmp/hehe-tunnel-restart.log
```

## How It Works

**Cloudflare Tunnel** exposes your local server (`http://localhost:8888`) to the internet via a public URL like `https://xxxx-xxxx-xxxx-xxxx.trycloudflare.com`.

Each tunnel restart generates a **new random URL** because we use Cloudflare's free quick tunnels (no account required).

**iMessage Notifications** are sent automatically via `AppleScript` when a new URL is generated, so you always know the current URL on your phone.

## Tunnel Protocol

The tunnel uses **HTTP/2** transport for reliability on restrictive networks. This ensures the tunnel stays connected even with connectivity issues.

To use a different protocol, modify the Makefile or tunnel-restart.sh:
```bash
# Change this:
cloudflared tunnel --protocol http2 --url http://localhost:8888

# To:
cloudflared tunnel --protocol quic --url http://localhost:8888
```

## Automation

A **cron job** automatically restarts the tunnel every 6 hours:
```bash
0 */6 * * * /Users/thanujanpuvikaran/Documents/repositories/hehe/tunnel-restart.sh
```

### Install Auto-Restart
```bash
make tunnel-keep-alive
```

### Remove Auto-Restart
```bash
make tunnel-keep-alive-remove
```

## Troubleshooting

### Tunnel shows "Tunnel not found"
- Old tunnel URL has expired
- Solution: Run `make tunnel-restart` to get a fresh URL

### Server not accessible via tunnel
- Server may not be running
- Solution: Run `make server` in another terminal

### iMessage not sending
- Messages app not open or not signed in
- AppleScript permissions not granted
- Solution: Open Messages.app, sign in, and run `make tunnel-imessage-test`

### View all running processes
```bash
make ps
```

## Current Status

**Server:** http://localhost:8888 (requires puzzle login)
**Tunnel URL:** Check iMessage or run `tail /tmp/hehe-tunnel-restart.log`
