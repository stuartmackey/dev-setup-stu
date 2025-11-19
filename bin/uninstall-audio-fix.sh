#!/usr/bin/env bash
set -e

TARGET="/etc/modprobe.d/snd_hda_intel.conf"

echo "Removing audio fix..."

if [ -f "$TARGET" ]; then
  rm "$TARGET"
  echo "Removed $TARGET"
else
  echo "Nothing to remove."
fi

echo "Reboot recommended."
