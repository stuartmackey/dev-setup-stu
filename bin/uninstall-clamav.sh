#!/usr/bin/env bash
set -euo pipefail

# Uninstall script for the ClamAV setup created by install-clamav.sh
# - Stops/disables services and timers
# - Removes periodic scan units/scripts/config
# - Uninstalls clamav package via paru (optional but enabled here)

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

if command -v paru >/dev/null 2>&1; then
  echo "==> Removing ClamAV package via paru..."
  # Remove clamav and unused dependencies. If you want to keep clamav,
  # comment this line out.
  paru -Rns --noconfirm clamav || true
else
  echo "paru not found; skipping package removal. Remove 'clamav' manually if desired."
fi

echo
echo "============================================================================="
echo "ClamAV services and automation have been removed."
echo "If you want a completely clean slate, you may also delete:"
echo "  - /var/log/clamav"
echo "  - /var/lib/clamav"
echo "  - /etc/clamav/*"
echo "============================================================================="
