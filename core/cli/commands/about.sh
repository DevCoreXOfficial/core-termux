#!/usr/bin/env bash

# `core about` is a full alias of `core show`.

import "@/cli/commands/show"

about_main() {
  show_main "$@"
}
