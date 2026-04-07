#!/bin/bash
# Restart Cloudflare tunnel and send iMessage with the new URL.
# Called by cron every 6 hours.

set -u

HEHE_DIR="/Users/thanujanpuvikaran/Documents/repositories/hehe"
LOG="/tmp/cloudflare-tunnel.log"
RUN_LOG="/tmp/hehe-tunnel-restart.log"
APPLESCRIPT="/tmp/hehe_cron_imsg.applescript"
PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

log_msg() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$RUN_LOG"
}

send_imessage() {
    local message="$1"
    local recipient="$2"
    cat > "$APPLESCRIPT" <<APPL
tell application "Messages"
    set svc to first service whose service type = iMessage
    set p to participant "$recipient" of svc
    send "$message" to p
end tell
APPL
    if ! /usr/bin/osascript "$APPLESCRIPT" >/dev/null 2>&1; then
        log_msg "iMessage send failed. Ensure Messages is open and Automation permission is granted."
        return 1
    fi
    return 0
}

RECIPIENT=$(awk -F= '/^IMESSAGE_RECIPIENT=/{print $2; exit}' "$HEHE_DIR/.env" 2>/dev/null | sed -E 's/^[[:space:]]+|[[:space:]]+$//g; s/^"|"$//g')
CLOUDFLARED_BIN=$(command -v cloudflared 2>/dev/null || true)

if [ -z "$CLOUDFLARED_BIN" ]; then
    log_msg "cloudflared not found in PATH: $PATH"
    exit 1
fi

log_msg "Starting tunnel restart with $CLOUDFLARED_BIN"

# Kill existing tunnel
pkill -f "cloudflared tunnel" 2>/dev/null || true
sleep 2

# Start new tunnel
nohup "$CLOUDFLARED_BIN" tunnel --url http://localhost:8888 > "$LOG" 2>&1 &

# Wait up to 60s for the URL to appear
URL=""
for i in $(seq 1 60); do
    URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG" 2>/dev/null | head -1)
    if [ -n "$URL" ]; then
        break
    fi
    sleep 1
done

if [ -n "$URL" ]; then
    log_msg "Tunnel URL detected: $URL"
    if [ -n "$RECIPIENT" ]; then
        send_imessage "Tunnel restarted: $URL" "$RECIPIENT" && log_msg "iMessage sent to $RECIPIENT"
    else
        log_msg "IMESSAGE_RECIPIENT is not set in .env"
    fi
else
    log_msg "No tunnel URL found within timeout. Last tunnel log lines:"
    tail -n 10 "$LOG" >> "$RUN_LOG" 2>/dev/null || true
    if [ -n "$RECIPIENT" ]; then
        send_imessage "Tunnel restart failed: no URL generated. Check /tmp/hehe-tunnel-restart.log" "$RECIPIENT" && log_msg "Failure iMessage sent to $RECIPIENT"
    fi
fi
