## Package Information

- **Name:** html2text
- **Tags:** html, conversion
- **Source:** https://github.com/Alir3z4/html2text
- **Dependencies:** None required by Core

## What is it?

Convert HTML to Markdown-formatted text.

## How to use it?

Example from the official README:

```bash
>>> import html2text
>>>
>>> print(html2text.html2text("<p><strong>Zed's</strong> dead baby, <em>Zed's</em> dead.</p>"))
**Zed's** dead baby, _Zed's_ dead.
```

Full documentation: https://github.com/Alir3z4/html2text

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `html2text`

### `--help` output

```text
Unrecognized command line option "--help", try "-help".
```


### Common commands

```bash
>>> import html2text
>>>
>>> print(html2text.html2text("<p><strong>Zed's</strong> dead baby, <em>Zed's</em> dead.</p>"))
**Zed's** dead baby, _Zed's_ dead.
```
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show html2text:es`.
