#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

if ! command -v npx >/dev/null 2>&1; then
  echo "Error: npx is required to run firebase-tools."
  exit 1
fi

if ! npx --yes firebase-tools login:list >/tmp/firebase_login_list.log 2>&1; then
  cat /tmp/firebase_login_list.log
  echo
  echo "Run: npx firebase-tools login"
  exit 1
fi

npx --yes firebase-tools deploy --only database,storage
