#!/usr/bin/env bash
set -euo pipefail

# Uninstall script for ClamAV package
# - Uninstalls clamav package via paru
# - For removing configuration/services, run unconfigure-clamav.sh separately

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root, e.g.: sudo $0"
  exit 1
fi

if command -v paru >/dev/null 2>&1; then
  echo "==> Removing ClamAV package via paru..."
  # Remove clamav and unused dependencies. If you want to keep clamav,
  # comment this line out.
  paru -Rns --noconfirm clamav || true
else
  echo "paru not found; skipping package removal. Remove 'clamav' manually if desired."
  exit 1
fi

echo
echo "============================================================================="
echo "ClamAV package has been removed."
echo
echo "Note: Configuration files, services, and timers may still be present."
echo "To remove those as well, run:"
echo "  sudo bash bin/unconfigure-clamav.sh"
echo "or"
echo "  make unconfigure-clamav"
echo
echo "If you want a completely clean slate, you may also delete:"
echo "  - /var/log/clamav"
echo "  - /var/lib/clamav"
echo "  - /etc/clamav/*"
echo "============================================================================="
