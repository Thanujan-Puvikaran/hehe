# Deployment Guide

This guide covers local development, HTTPS, Firebase rules publishing, and Cloudflare sharing.

## 1. Local Development Setup

1. Create and activate virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

2. Configure environment variables:

```bash
cp .env.example .env
# Edit .env and set strong passwords.
```

3. Start server:

```bash
source .venv/bin/activate
source .env
python server.py
```

4. Verify health endpoint:

```bash
curl -s http://localhost:8888/health
```

### Build Production Assets (Optional)

Before production deployment, minify CSS/JS for optimal performance:

```bash
npm run build
```

This reduces asset sizes by 28% (15.1 KB → 10.8 KB). HTML files are pre-configured to use minified versions.

## 2. Enable Local HTTPS (Self-Signed)

1. Generate certs:

```bash
chmod +x scripts/generate_local_ssl.sh
./scripts/generate_local_ssl.sh
```

2. Start HTTPS server:

```bash
source .venv/bin/activate
source .env
ENABLE_HTTPS=true SSL_CERTFILE=cert.pem SSL_KEYFILE=key.pem python server.py
```

3. Open:

```text
https://localhost:8888
```

Note: browser warning is expected for self-signed certificates.

## 3. Publish Firebase Rules

Use these files in Firebase Console:

- Storage Rules: `firebase-storage-rules.txt`
- Realtime Database Rules: `firebase-database-rules.json`

Console locations:

1. Storage > Rules > paste file content > Publish.
2. Realtime Database > Rules > paste file content > Publish.

Or deploy from this repo after authenticating once:

```bash
npx firebase-tools login
./scripts/push_firebase_rules.sh
```

## 4. Share Through Cloudflare Tunnel

### Quick temporary URL

```bash
./scripts/share_quick_tunnel.sh
```

### Stable custom domain

Follow the complete instructions in `CLOUDFLARE_TUNNEL_SETUP.md`.

## 5. Offline and Performance Features

Implemented in app:

- Client-side image compression before upload.
- Native lazy loading for gallery images.
- Service worker shell caching (`sw.js`).
- Offline banner and queued upload retries.

## 6. Troubleshooting

### Server fails with missing password

Symptom:

```text
Environment variable BIRTHDAY_PAGE_PASSWORD is not set
```

Fix:

```bash
source .env
```

### HTTPS fails to start

Checks:

- `cert.pem` and `key.pem` exist in project root.
- `SSL_CERTFILE` and `SSL_KEYFILE` paths are correct.
- Files are readable by current user.

### Login loops back to login page

Checks:

- Correct password and correct page (`/` for public, `/upload.html` for admin).
- Cookies are enabled in browser.
- Session timeout has not expired.

### Uploads fail

Checks:

- Browser is online.
- Firebase anonymous auth is enabled.
- Firebase rules were published.
- File is image and under size limits.

### Photos not visible on index page

Checks:

- Data exists in Realtime Database under `photos`.
- Browser console for Firebase/network errors.
- Hard refresh to bypass stale cache.

## 7. Recommended Verification Checklist

Run before sharing:

1. `python -m unittest test_server -v`
2. Public login works and opens `/index.html`.
3. Admin login works and opens `/upload.html`.
4. Upload, delete, and drawing save all succeed.
5. `/health` returns `{"status":"ok", ...}`.
6. Tunnel URL opens login page from external network.
