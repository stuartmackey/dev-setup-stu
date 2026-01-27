#!/usr/bin/env bash
set -euo pipefail

# Unconfigure script for ClamAV setup
# - Stops/disables services and timers
# - Removes periodic scan units/scripts/config
# - Leaves the ClamAV package installed

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root, e.g.: sudo $0"
  exit 1
fi

SCAN_CONF="/etc/clamav/periodic-scan.conf"
SCAN_SCRIPT="/usr/local/sbin/clamav-periodic-scan.sh"
SCAN_SERVICE="/etc/systemd/system/clamav-periodic-scan.service"
SCAN_TIMER="/etc/systemd/system/clamav-periodic-scan.timer"

echo "==> Stopping and disabling periodic scan timer/service (if present)..."
systemctl disable --now clamav-periodic-scan.timer 2>/dev/null || true
systemctl disable --now clamav-periodic-scan.service 2>/dev/null || true

echo "==> Stopping and disabling ClamAV daemon and freshclam units (if present)..."
systemctl disable --now clamav-daemon.service 2>/dev/null || true
systemctl disable --now clamav-freshclam-once.timer 2>/dev/null || true
systemctl disable --now clamav-freshclam.service 2>/dev/null || true

echo "==> Removing periodic scan units and script..."
rm -f "$SCAN_SERVICE" "$SCAN_TIMER" "$SCAN_SCRIPT"

echo "==> Optionally removing periodic scan config..."
if [[ -f "$SCAN_CONF" ]]; then
  rm -f "$SCAN_CONF"
fi

echo "==> Reloading systemd daemon..."
systemctl daemon-reload

echo "==> Leaving /var/log/clamav and /var/lib/clamav intact (logs & DB)."

echo
echo "============================================================================="
echo "ClamAV configuration and services have been removed."
echo "The ClamAV package is still installed."
echo
echo "To remove the package as well, run:"
echo "  sudo bash bin/uninstall-clamav.sh"
echo "or"
echo "  make uninstall-clamav"
echo
echo "If you want a completely clean slate, you may also delete:"
echo "  - /var/log/clamav"
echo "  - /var/lib/clamav"
echo "  - /etc/clamav/*"
echo "============================================================================="
