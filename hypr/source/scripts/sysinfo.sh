#!/usr/bin/env bash
# Öffnet ein schwebendes, mittiges Terminal im Inhaltsformat mit fastfetch.
set -uo pipefail

log_file=/tmp/sysinfo.log
: > "$log_file"
log() { printf '%s %s\n' "$(date +%T)" "$*" >> "$log_file"; }

fastfetch_config="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/config.jsonc"

logo_left=0
logo_block=15
if [[ -r "$fastfetch_config" ]]; then
  logo_width=$(sed -n 's/.*"width"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$fastfetch_config" | head -1)
  logo_height=$(sed -n 's/.*"height"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$fastfetch_config" | head -1)
  padding_left=$(sed -n 's/.*"left"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$fastfetch_config" | head -1)
  padding_right=$(sed -n 's/.*"right"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$fastfetch_config" | head -1)
  padding_top=$(sed -n 's/.*"top"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$fastfetch_config" | head -1)
  logo_left=$(( ${padding_left:-0} + ${logo_width:-0} + ${padding_right:-0} ))
  logo_block=$(( ${padding_top:-0} + ${logo_height:-0} ))
fi

# Textspalte der Ausgabe vermessen (ohne Logo, da das Bild-Logo nur im Terminal rendert)
ff_out=$(fastfetch --logo-type none --pipe 2>/dev/null || true)

text_width=$(printf '%s\n' "$ff_out" | LC_ALL=C.UTF-8 awk '{
  s = $0
  while (match(s, /\033\[[0-9;]*[A-Za-z]/)) s = substr(s, 1, RSTART - 1) substr(s, RSTART + RLENGTH)
  if (length(s) > m) m = length(s)
}
END { print m + 0 }')

text_height=$(printf '%s\n' "$ff_out" | LC_ALL=C.UTF-8 awk 'END { print NR + 0 }')

columns=$(( logo_left + text_width + 4 ))
rows=$(( (text_height > logo_block ? text_height : logo_block) + 4 ))
log "columns=$columns rows=$rows text_width=$text_width text_height=$text_height logo_left=$logo_left"

# remember_window_size=no: verhindert, dass kitty eine alte Fenstergröße wiederherstellt
kitty \
  --class sysinfo-term \
  --title "System-Informationen" \
  -o remember_window_size=no \
  -o initial_window_width="${columns}c" \
  -o initial_window_height="${rows}c" \
  -e bash -c 'fastfetch; printf "\n"; read -rsn1 -p "Drücke eine Taste zum Schließen …" _; printf "\r\033[K"'
log "done"