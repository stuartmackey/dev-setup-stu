#!/usr/bin/env bash
set -euo pipefail

# ClamAV installation for Arch Linux using paru
# - Installs clamav package only
# - For configuration, run configure-clamav.sh separately

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root, e.g.: sudo $0"
  exit 1
fi

if ! command -v paru >/dev/null 2>&1; then
  echo "paru is not installed or not in PATH."
  echo "Install paru first, then re-run this script."
  exit 1
fi

echo "==> Installing ClamAV via paru..."
paru -S --needed --noconfirm clamav

echo
echo "============================================================================="
echo "ClamAV package installed successfully."
echo
echo "To configure ClamAV (services, timers, periodic scans), run:"
echo "  sudo bash bin/configure-clamav.sh"
echo "or"
echo "  make configure-clamav"
echo "============================================================================="
