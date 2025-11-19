#!/usr/bin/env bash
set -euo pipefail

# Mode: region (default) or full
MODE="${1:-region}"

# Temporary file just to feed Satty
TMPDIR="${XDG_RUNTIME_DIR:-/tmp}"
FILE="$(mktemp --suffix=.png "$TMPDIR/satty-XXXXXX")"

case "$MODE" in
region)
  # Let slurp fail gracefully if you cancel
  GEOM="$(slurp || true)"
  if [ -z "${GEOM:-}" ]; then
    echo "Selection cancelled"
    rm -f "$FILE"
    exit 0
  fi

  grim -g "$GEOM" "$FILE"
  ;;
full)
  grim "$FILE"
  ;;
*)
  echo "Usage: $0 [region|full]" >&2
  rm -f "$FILE"
  exit 1
  ;;
esac

# Open Satty with the captured file
satty --filename "$FILE"

# Remove the temp file after Satty closes
[ -f "$FILE" ] && rm -f "$FILE"
