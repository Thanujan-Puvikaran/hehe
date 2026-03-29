#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

PORT="${PORT:-8888}"
ORIGIN_URL="http://localhost:${PORT}"

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "Error: cloudflared is not installed."
  echo "Install with: brew install cloudflared"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is not installed."
  exit 1
fi

if [[ -f ".env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if [[ -z "${BIRTHDAY_PAGE_PASSWORD:-}" ]]; then
  echo "Error: BIRTHDAY_PAGE_PASSWORD is not set."
  echo "Set it in .env or export it before running this script."
  exit 1
fi

server_started_by_script="false"

if curl -fsS "$ORIGIN_URL" >/dev/null 2>&1; then
  echo "Server already running at $ORIGIN_URL"
else
  echo "Starting local server on $ORIGIN_URL ..."
  python3 server.py >/tmp/hehe_server.log 2>&1 &
  SERVER_PID=$!
  server_started_by_script="true"

  sleep 1
  if ! kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    echo "Server failed to start. Check /tmp/hehe_server.log"
    exit 1
  fi
fi

cleanup() {
  if [[ "$server_started_by_script" == "true" ]]; then
    if [[ -n "${SERVER_PID:-}" ]] && kill -0 "$SERVER_PID" >/dev/null 2>&1; then
      kill "$SERVER_PID" >/dev/null 2>&1 || true
    fi
  fi
}
trap cleanup EXIT INT TERM

echo "Starting Cloudflare quick tunnel..."
echo "Press Ctrl+C to stop sharing."
echo

cloudflared tunnel --url "$ORIGIN_URL" 2>&1 | while IFS= read -r line; do
  echo "$line"
  if [[ "$line" =~ https://[-a-z0-9]+\.trycloudflare\.com ]]; then
    echo
    echo "Public URL: ${BASH_REMATCH[0]}"
    echo "Share this URL with allowed people only."
    echo
  fi
done
