#!/usr/bin/env bash
set -euo pipefail

# Generate self-signed certs for local HTTPS development.
# Output files are written to the project root as cert.pem/key.pem.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERT_FILE="${PROJECT_ROOT}/cert.pem"
KEY_FILE="${PROJECT_ROOT}/key.pem"
DAYS="${DAYS:-365}"

if ! command -v openssl >/dev/null 2>&1; then
  echo "Error: openssl is not installed."
  exit 1
fi

if [[ -f "${CERT_FILE}" || -f "${KEY_FILE}" ]]; then
  echo "Existing cert/key detected in project root."
  echo "Remove cert.pem/key.pem first if you want to regenerate them."
  exit 1
fi

openssl req \
  -x509 \
  -newkey rsa:4096 \
  -keyout "${KEY_FILE}" \
  -out "${CERT_FILE}" \
  -days "${DAYS}" \
  -nodes \
  -subj "/C=US/ST=Local/L=Local/O=OurMemories/OU=Dev/CN=localhost"

chmod 600 "${KEY_FILE}"

cat <<EOF

Generated:
  - ${CERT_FILE}
  - ${KEY_FILE}

To run server with HTTPS:
  ENABLE_HTTPS=true SSL_CERTFILE=cert.pem SSL_KEYFILE=key.pem python server.py

EOF
