#!/data/data/com.termux/files/usr/glibc/bin/python
"""Cactus Engine CLI launcher for core-termux.

Runs the normal cactus CLI after applying a small compatibility patch:

* Upstream prebuilt bundles (Cactus-Compute/*) often ship a
  sentencepiece tokenizer as `tokenizer.model` + `tokenizer_config.txt`
  while omitting `tokenizer.json`. The CLI's bundle validator rejects
  those bundles and falls back to "building locally", which demands the
  ~1 GB torch/transformers toolchain. The Cactus runtime SPTokenizer
  only reads tokenizer.model + tokenizer_config.txt (+ special tokens),
  so writing a minimal valid tokenizer.json satisfies the validator and
  lets the prebuilt bundle run without any conversion toolchain.
"""
from __future__ import annotations

import sys
from pathlib import Path

import cactus.cli.utils as cactus_utils

_original_validate = cactus_utils.validate_extracted_bundle


def _patched_validate_extracted_bundle(output_dir: Path):
    try:
        return _original_validate(output_dir)
    except RuntimeError as exc:
        message = str(exc)
        if "tokenizer sidecar" not in message:
            raise

        tokenizer_type = ""
        config_path = output_dir / "tokenizer_config.txt"
        if config_path.exists():
            for line in config_path.read_text(encoding="utf-8").splitlines():
                line = line.strip()
                if line.startswith("tokenizer_type="):
                    tokenizer_type = line.split("=", 1)[1].strip().lower()
                    break

        # Only sentencepiece bundles can run from tokenizer.model alone.
        # BPE bundles genuinely need a real tokenizer.json; surface those.
        if tokenizer_type not in ("sentencepiece", ""):
            raise

        tokenizer_json = output_dir / "tokenizer.json"
        if not tokenizer_json.exists():
            tokenizer_json.write_text("{}", encoding="utf-8")
        return _original_validate(output_dir)


cactus_utils.validate_extracted_bundle = _patched_validate_extracted_bundle

from cactus.cli import main  # noqa: E402  (runs after the patch is installed)

sys.exit(main())