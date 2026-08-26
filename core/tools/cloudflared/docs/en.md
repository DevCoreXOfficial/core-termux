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

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `cloudflared`

### `--help` output

```text
   cloudflared - Cloudflare's command-line tool and agent

USAGE:
   cloudflared [global options] [command] [command options]

VERSION:
   2026.8.2 (built 2026.08.14-12:33 UTC)

DESCRIPTION:
   cloudflared connects your machine or user identity to Cloudflare's global network.
     You can use it to authenticate a session to reach an API behind Access, route web traffic to this machine,
     and configure access control.

     See https://developers.cloudflare.com/cloudflare-one/connections/connect-apps for more in-depth documentation.

COMMANDS:
   update     Update the agent if a new version exists
   version    Print the version
   proxy-dns  dns-proxy feature is no longer supported
   tail       Stream logs from a remote cloudflared
   service    Manages the cloudflared Termux runit service
   help, h    Shows a list of commands or help for one command
   Access:
     access, forward  access <subcommand>
   Tunnel:
     tunnel  Use Cloudflare Tunnel to expose private services to the Internet or to Cloudflare connected private users.

GLOBAL OPTIONS:
   --output value                               Output format for the logs (default, json) (default: "default") [$TUNNEL_MANAGEMENT_OUTPUT, $TUNNEL_LOG_OUTPUT]
   --proxy-dns                                  (default: false)
   --proxy-dns-port value                       (default: 0)
   --proxy-dns-address value
   --proxy-dns-upstream value                   (accepts multiple inputs)
   --proxy-dns-max-upstream-conns value         (default: 0)
   --proxy-dns-bootstrap value                  (accepts multiple inputs)
   --credentials-file value, --cred-file value  Filepath at which to read/write the tunnel credentials [$TUNNEL_CRED_FILE]
   --region value                               Cloudflare Edge region to connect to. Omit or set to empty to connect to the global region. [$TUNNEL_REGION]
   --edge-ip-version value                      Cloudflare Edge IP address version to connect with. {4, 6, auto} (default: "auto") [$TUNNEL_EDGE_IP_VERSION]
   --edge-bind-address value                    Bind to IP address for outgoing connections to Cloudflare Edge. [$TUNNEL_EDGE_BIND_ADDRESS]
   --label value                                Use this option to give a meaningful label to a specific connector. When a tunnel starts up, a connector id unique to the tunnel is generated. This is a uuid. To make it easier to identify a connector, we will use the hostname of the machine the tunnel is running on along with the connector ID. This option exists if one wants to have more control over what their individual connectors are called.
   --post-quantum, --pq                         When given creates an experimental post-quantum secure tunnel (default: false) [$TUNNEL_POST_QUANTUM]
   --management-diagnostics                     Enables the in-depth diagnostic routes to be made available over the management service (/debug/pprof, /metrics, etc.) (default: true) [$TUNNEL_MANAGEMENT_DIAGNOSTICS]
   --overwrite-dns, -f                          Overwrites existing DNS records with this hostname (default: false) [$TUNNEL_FORCE_PROVISIONING_DNS]
   --help, -h                                   show help (default: false)
   --version, -v, -V                            Print the version (default: false)

COPYRIGHT:
   (c) 2026 Cloudflare Inc.
   Your installation of cloudflared software constitutes a symbol of your signature indicating that you accept
   the terms of the Apache License Version 2.0 (https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/license),
   Terms (https://www.cloudflare.com/terms/) and Privacy Policy (https://www.cloudflare.com/privacypolicy/).
```

