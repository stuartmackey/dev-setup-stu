#!/usr/bin/env bash
set -euo pipefail

# Maps Caps Lock to Control in Hyprland (or reverts with --revert)

input_conf="${HOME}/.config/hypr/input.conf"

revert=false
if [ "${1:-}" = "--revert" ]; then
  revert=true
fi

if [ ! -f "$input_conf" ]; then
  echo "Hyprland input.conf not found — skipping keyboard setup"
  exit 0
fi

if [ "$revert" = true ]; then
  if grep -q 'ctrl:nocaps' "$input_conf"; then
    sed -i 's/kb_options = ctrl:nocaps/# kb_options =/' "$input_conf"
    hyprctl reload 2>/dev/null || true
    echo "Reverted Caps Lock mapping in Hyprland input.conf"
  else
    echo "Caps Lock → Control not set — nothing to revert"
  fi
elif grep -q 'kb_options' "$input_conf" && ! grep -q 'ctrl:nocaps' "$input_conf"; then
  sed -i 's/kb_options = .*/kb_options = ctrl:nocaps/' "$input_conf"
  echo "Updated Caps Lock → Control in Hyprland input.conf"
  hyprctl reload 2>/dev/null || true
elif ! grep -q 'kb_options' "$input_conf"; then
  sed -i '/^input {/a \  kb_options = ctrl:nocaps' "$input_conf"
  echo "Added Caps Lock → Control to Hyprland input.conf"
  hyprctl reload 2>/dev/null || true
else
  echo "Caps Lock → Control already set"
fi
