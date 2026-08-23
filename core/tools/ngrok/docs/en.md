## Package Information

- **Name:** ngrok
- **Tags:** tunnel, localhost, expose
- **Project:** https://ngrok.com
- **Dependencies:** nodejs

## What is it?

Secure tunnel to expose local servers to the internet

**Package:** ngrok  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://ngrok.com  
**Type:** Node.js global module (npm)  
**License:** Apache 2.0 (ngrok itself has proprietary components)

### Description

Ngrok creates secure tunnels from the public internet to your local development server. It provides inspectable traffic, replay requests, and authentication, making it essential for testing webhooks and sharing local applications.

### Dependencies

- Node.js LTS (nodejs-lts)

### Install

```bash
core install npm --ngrok
```

### Uninstall

```bash
core uninstall npm --ngrok
```

### Update

```bash
core update npm --ngrok
```

### Notes

- Command: `ngrok`
- Requires free account for some features
- Supports HTTP, HTTPS, and TCP tunnels
- Dashboard at http://localhost:4040

## How to use it?

```bash
core install ngrok      # install
core update ngrok       # update
core uninstall ngrok    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show ngrok:es`.
