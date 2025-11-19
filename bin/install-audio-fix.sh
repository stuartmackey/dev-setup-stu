#!/usr/bin/env bash
set -e

TARGET="/etc/modprobe.d/snd_hda_intel.conf"
LINE="options snd_hda_intel power_save=0"

echo "Applying audio buzzing fix..."

echo "$LINE" | tee "$TARGET" >/dev/null

echo "Written: $LINE"
echo "Reboot recommended, or run: make reload"
