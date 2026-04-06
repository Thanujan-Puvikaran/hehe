#!/bin/bash
# Restart Cloudflare tunnel and send iMessage with the new URL.
# Called by cron every 6 hours.

HEHE_DIR="/Users/thanujanpuvikaran/Documents/repositories/hehe"
LOG="/tmp/cloudflare-tunnel.log"
APPLESCRIPT="/tmp/hehe_cron_imsg.applescript"
RECIPIENT=$(grep IMESSAGE_RECIPIENT "$HEHE_DIR/.env" | cut -d= -f2)

# Kill existing tunnel
pkill -f "cloudflared tunnel" 2>/dev/null
sleep 2

# Start new tunnel
nohup cloudflared tunnel --url http://localhost:8888 > "$LOG" 2>&1 &

# Wait up to 30s for the URL to appear
for i in $(seq 1 30); do
    URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG" 2>/dev/null | head -1)
    if [ -n "$URL" ]; then break; fi
    sleep 1
done

# Send iMessage if we got a URL and have a recipient
if [ -n "$URL" ] && [ -n "$RECIPIENT" ]; then
    cat > "$APPLESCRIPT" <<APPL
tell application "Messages"
    set svc to first service whose service type = iMessage
    set p to participant "$RECIPIENT" of svc
    send "Tunnel restarted: $URL" to p
end tell
APPL
    osascript "$APPLESCRIPT"
fi
