# Udocker

Run Docker containers without root privileges

**Package:** udocker  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/indigo-dc/udocker  
**Type:** Container tool (pkg)  
**License:** Apache 2.0

## Description

Udocker is a tool that allows you to execute Docker containers in user space without requiring root privileges. It works by using chroot, proot, and other user-space mechanisms to provide container-like environments on systems where Docker is not available.

## Dependencies

- Installed via pkg

## Install

```bash
core install dev --udocker
```

## Uninstall

```bash
core uninstall dev --udocker
```

## Update

```bash
core update dev --udocker
```

## Notes

- Command: `udocker`
- No root required
- Supports pulling from Docker Hub
- Limited compared to full Docker

