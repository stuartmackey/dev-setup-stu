#!/usr/bin/env bash
set -e

echo "Reloading snd_hda_intel driver..."

if modprobe -r snd_hda_intel; then
  modprobe snd_hda_intel
  echo "Driver reloaded."
else
  echo "Could not unload driver. A reboot may be required."
fi
