## Package Information

- **Name:** cloudflared
- **Tags:** tunnel, dns, cloudflare
- **Project:** https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/
- **Dependencies:** None required by Core

## What is it?

Cloudflare Tunnel client for secure connections

**Package:** cloudflared  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://developers.cloudflare.com/cloudflare-one/connections/connect-networks  
**Type:** Networking tool (pkg)  
**License:** Apache 2.0 / Cloudflare License

### Description

Cloudflared creates secure tunnels from your local server to Cloudflare's edge network. It exposes local services to the internet through Cloudflare without opening firewall ports, providing DDoS protection and SSL/TLS encryption.

### Dependencies

- Installed via pkg

### Install

```bash
core install cloudflared
```

### Uninstall

```bash
core uninstall cloudflared
```

### Update

```bash
core update cloudflared
```

### Notes

- Command: `cloudflared`
- Requires Cloudflare account for tunnel setup
- Supports load balancing and failover

## How to use it?

```bash
core install cloudflared      # install
core update cloudflared       # update
core uninstall cloudflared    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show cloudflared:es`.
