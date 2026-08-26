## Package Information

- **Name:** Oh-My-Pi
- **Tags:** ai, agent, coding
- **Source:** https://github.com/can1357/oh-my-pi
- **Dependencies:** None required by Core

## What is it?

⌥ Coding agent with the IDE wired in

## How to use it?

Example from the official README:

```bash
{
  inputs.omp.url = "github:can1357/oh-my-pi";

  # In your Home Manager module:
  imports = [ inputs.omp.homeManagerModules.default ];
  programs.omp = {
    enable = true;
    settings.startup.quiet = true;
  };
}
```

Full documentation: https://github.com/can1357/oh-my-pi

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show oh-my-pi:es`.
