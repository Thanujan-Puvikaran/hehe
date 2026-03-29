# Cloudflare Tunnel Setup (Private Share)

This project can be shared privately using Cloudflare Tunnel.

## Quick Temporary Share (No DNS Needed)

Use this when you want a fast URL right now.

1. Start from the project folder.
2. Run:

```bash
./scripts/share_quick_tunnel.sh
```

The script will:
- load `.env`
- ensure `BIRTHDAY_PAGE_PASSWORD` exists
- start `server.py` if needed
- start a quick Cloudflare tunnel
- print the public URL (`https://...trycloudflare.com`)

Keep the terminal open. When you stop it (`Ctrl+C`), the URL stops working.

## Manual Quick Command

If your server is already running:

```bash
cloudflared tunnel --url http://localhost:8888
```

## Custom Domain (Stable URL)

Yes: if you want a specific URL like `birthday.yourdomain.com`, you need DNS.

Requirements:
- a domain on Cloudflare
- Cloudflare Zero Trust tunnel created

Steps:

1. Create named tunnel:

```bash
cloudflared tunnel create hehe-birthday
```

2. Route DNS hostname to tunnel:

```bash
cloudflared tunnel route dns hehe-birthday birthday.yourdomain.com
```

3. Create config file at `~/.cloudflared/config.yml`:

```yaml
tunnel: hehe-birthday
credentials-file: /Users/<your-user>/.cloudflared/<tunnel-id>.json

ingress:
  - hostname: birthday.yourdomain.com
    service: http://localhost:8888
  - service: http_status:404
```

4. Run named tunnel:

```bash
cloudflared tunnel run hehe-birthday
```

Now your stable URL is:

`https://birthday.yourdomain.com`

## Privacy Best Practice

For a private page, use multiple layers:
- Cloudflare tunnel URL secrecy
- your app password (`BIRTHDAY_PAGE_PASSWORD`)
- Cloudflare Access email allowlist (recommended for strict privacy)

Cloudflare Access lets only selected emails open the site before your app login page appears.
