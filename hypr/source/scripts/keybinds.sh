#!/usr/bin/env bash
set -euo pipefail
exec qs -c desktop ipc call menu toggle keybinds
