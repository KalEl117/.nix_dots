#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C.UTF-8

# Keep both replies intact: device descriptions may contain arbitrary JSON text.
audio_objects=$(pactl --format=json list)
audio_info=$(pactl --format=json info)
printf '{"objects":%s,"info":%s}\n' "$audio_objects" "$audio_info"
