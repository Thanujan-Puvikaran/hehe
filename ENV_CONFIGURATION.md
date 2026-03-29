# Environment Configuration Guide

This project uses environment variables to configure passwords and security settings.

## Required Environment Variables

### `BIRTHDAY_PAGE_PASSWORD` (Required)
The password for accessing the public photo gallery page (`index.html`).

```bash
export BIRTHDAY_PAGE_PASSWORD="your-secure-password-here"
```

**Requirements:**
- Minimum 8 characters
- Recommended: 12+ characters with mixed case, numbers, and symbols
- Do NOT use in public/shared code repositories

### `ADMIN_PAGE_PASSWORD` (Optional)
The password for accessing the admin upload page (`upload.html`).

If not set, falls back to using `BIRTHDAY_PAGE_PASSWORD` for both areas.

```bash
export ADMIN_PAGE_PASSWORD="separate-admin-password"
```

**When to use separate passwords:**
- Use the same password: Simple setup, one password to remember
- Use different passwords: Stronger security, admin area protected separately

## Firebase Runtime Configuration (Required)

These values are served by `server.py` at `/firebase-config.json` so they are not hardcoded in frontend files.

### `FIREBASE_API_KEY`
Firebase web API key.

```bash
export FIREBASE_API_KEY="your-firebase-web-api-key"
```

### `FIREBASE_AUTH_DOMAIN`

```bash
export FIREBASE_AUTH_DOMAIN="your-project.firebaseapp.com"
```

### `FIREBASE_DATABASE_URL`

```bash
export FIREBASE_DATABASE_URL="https://your-project-default-rtdb.region.firebasedatabase.app"
```

### `FIREBASE_PROJECT_ID`

```bash
export FIREBASE_PROJECT_ID="your-project-id"
```

### `FIREBASE_STORAGE_BUCKET`

```bash
export FIREBASE_STORAGE_BUCKET="your-project.firebasestorage.app"
```

### `FIREBASE_MESSAGING_SENDER_ID`

```bash
export FIREBASE_MESSAGING_SENDER_ID="1234567890"
```

### `FIREBASE_APP_ID`

```bash
export FIREBASE_APP_ID="1:1234567890:web:abcdef1234567890"
```

## Optional Environment Variables

### `ENABLE_HTTPS`
Enable HTTPS/SSL encryption (default: `false`)

```bash
export ENABLE_HTTPS="true"
```

Requires `cert.pem` and `key.pem` files in the project directory.

### `SSL_CERTFILE`
Path to SSL certificate file (default: `cert.pem`)

```bash
export SSL_CERTFILE="/path/to/cert.pem"
```

### `SSL_KEYFILE`
Path to SSL private key file (default: `key.pem`)

```bash
export SSL_KEYFILE="/path/to/key.pem"
```

## Quick Start (macOS/Linux)

### Using the virtual environment:

```bash
# Activate virtual environment
source .venv/bin/activate

# Set passwords
export BIRTHDAY_PAGE_PASSWORD="my-secret-password"
export ADMIN_PAGE_PASSWORD="admin-secret-password"

# Start server
python server.py
```

### One-liner:

```bash
BIRTHDAY_PAGE_PASSWORD="my-secret-password" ADMIN_PAGE_PASSWORD="admin-secret-password" python server.py
```

### Or use a .env file with direnv:

```bash
# Create .env file
cat > .env << 'EOF'
export BIRTHDAY_PAGE_PASSWORD="my-secret-password"
export ADMIN_PAGE_PASSWORD="admin-secret-password"
EOF

# Install direnv: https://direnv.net/docs/installation.html
direnv allow

# Now environment variables are loaded automatically
python server.py
```

## Quick Start (Windows)

```batch
# Set passwords in Command Prompt
set BIRTHDAY_PAGE_PASSWORD=my-secret-password
set ADMIN_PAGE_PASSWORD=admin-secret-password

# Start server
python server.py
```

Or in PowerShell:

```powershell
$env:BIRTHDAY_PAGE_PASSWORD="my-secret-password"
$env:ADMIN_PAGE_PASSWORD="admin-secret-password"
python server.py
```

## Session Configuration

The server automatically manages sessions:

- **Public Gallery**: 60-minute session timeout
- **Admin Upload**: 30-minute session timeout
- **Max concurrent users**: 1 per session type (can have 1 public + 1 admin at same time from different IPs)

## Security Best Practices

1. ✅ Use strong passwords (12+ characters, mixed case, numbers, symbols)
2. ✅ Use separate passwords for public and admin areas
3. ✅ Enable HTTPS for production deployments
4. ✅ Never commit passwords to Git
5. ✅ Use environment variables or .env files
6. ✅ Rotate passwords periodically
7. ✅ Use IP whitelisting if possible (for your network)

## Deployment

### Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY . .

ENV BIRTHDAY_PAGE_PASSWORD=your-secret-password
ENV ADMIN_PAGE_PASSWORD=your-admin-password

CMD ["python", "server.py"]
```

### GitHub Actions / CI/CD

Store passwords as **Secrets** in your repository settings, then use in workflows:

```yaml
env:
  BIRTHDAY_PAGE_PASSWORD: ${{ secrets.BIRTHDAY_PAGE_PASSWORD }}
  ADMIN_PAGE_PASSWORD: ${{ secrets.ADMIN_PAGE_PASSWORD }}
```

### Deployment with Cloudflare Tunnel

```bash
# With environment variables
BIRTHDAY_PAGE_PASSWORD="password" ADMIN_PAGE_PASSWORD="admin-pass" cloudflared tunnel --url http://localhost:8888
```

## Troubleshooting

**"Environment variable BIRTHDAY_PAGE_PASSWORD is not set"**
- Make sure to export the variable before running the server
- Check that you're in the correct terminal session

**"Invalid Password"**
- Verify you're using the correct password
- Check for typos and spaces
- Remember: passwords are case-sensitive

**"Someone else is currently using this page"**
- Another user is logged in on a different IP
- Wait for their session to expire (30-60 minutes)
- Server admin can restart to reset sessions

## Advanced: Testing with Different Passwords

```bash
# Terminal 1: Public gallery with password "public"
BIRTHDAY_PAGE_PASSWORD="public" ADMIN_PAGE_PASSWORD="admin" python server.py

# Terminal 2 & 3: Test with curl (or browser simultaneously)
curl -X POST http://localhost:8888/login -d "password=public&redirect=index"
curl -X POST http://localhost:8888/login -d "password=admin&redirect=upload"
```
