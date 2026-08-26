## Package Information

- **Name:** OpenSSH
- **Tags:** ssh, remote, scp
- **Project:** https://www.openssh.com
- **Source:** https://github.com/openssh/openssh-portable
- **Dependencies:** None required by Core

## What is it?

Portable OpenSSH

## How to use it?

Example from the official README:

```bash
tar zxvf openssh-X.YpZ.tar.gz
cd openssh
./configure # [options]
make && make tests
```

Full documentation: https://www.openssh.com

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show openssh:es`.
