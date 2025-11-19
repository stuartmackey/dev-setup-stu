#!/usr/bin/env bash
set -euo pipefail

### Hyprland / Wayland Screensharing Setup (Omarchy-style)
### - Arch Linux
### - PipeWire + xdg-desktop-portal-wlr
### - Optional: clear existing portal config
###
### Usage:
###   ./setup_hyprland_screensharing.sh          # normal install / setup
###   ./setup_hyprland_screensharing.sh --clear  # clear old config, then install / setup

CLEAR_MODE=false

for arg in "$@"; do
  case "$arg" in
  --clear)
    CLEAR_MODE=true
    ;;
  -h | --help)
    echo "Usage: $0 [--clear]"
    exit 0
    ;;
  *)
    echo "Unknown argument: $arg"
    echo "Usage: $0 [--clear]"
    exit 1
    ;;
  esac
done

echo "==> Hyprland screensharing setup (Arch)"

# --- Basic sanity check -------------------------------------------------------
if ! grep -qi 'ID=arch' /etc/os-release 2>/dev/null; then
  echo "!! This script is designed for Arch Linux. Aborting."
  exit 1
fi

# --- Packages -----------------------------------------------------------------
REQUIRED_PACKAGES=(
  pipewire
  pipewire-alsa
  pipewire-pulse
  pipewire-jack
  wireplumber
  xdg-desktop-portal
  xdg-desktop-portal-wlr
  grim         # optional but nice for screenshots
  slurp        # optional selection tool
  wl-clipboard # clipboard helper
)

echo "==> Installing required packages (using pacman)..."
sudo pacman -Syu --needed "${REQUIRED_PACKAGES[@]}"

# --- Optional clear of existing portals config --------------------------------
if [ "$CLEAR_MODE" = true ]; then
  echo "==> CLEAR MODE: cleaning up existing portal configuration"

  # Stop portal services for this user if running
  systemctl --user stop xdg-desktop-portal.service 2>/dev/null || true
  systemctl --user stop xdg-desktop-portal-wlr.service 2>/dev/null || true

  # Backup system-wide portals.conf if it exists
  if [ -f /etc/xdg-desktop-portal/portals.conf ]; then
    TS=$(date +'%Y%m%d_%H%M%S')
    echo "   - Backing up /etc/xdg-desktop-portal/portals.conf -> /etc/xdg-desktop-portal/portals.conf.bak-${TS}"
    sudo mkdir -p /etc/xdg-desktop-portal
    sudo cp /etc/xdg-desktop-portal/portals.conf "/etc/xdg-desktop-portal/portals.conf.bak-${TS}"
    sudo rm /etc/xdg-desktop-portal/portals.conf
  fi

  # Remove user-specific portals.conf
  if [ -f "${HOME}/.config/xdg-desktop-portal/portals.conf" ]; then
    echo "   - Removing ${HOME}/.config/xdg-desktop-portal/portals.conf"
    rm -f "${HOME}/.config/xdg-desktop-portal/portals.conf"
  fi
fi

# --- Ensure preferred portal backend is wlr -----------------------------------
echo "==> Writing /etc/xdg-desktop-portal/portals.conf to prefer xdg-desktop-portal-wlr"

sudo mkdir -p /etc/xdg-desktop-portal

sudo tee /etc/xdg-desktop-portal/portals.conf >/dev/null <<'EOF'
[preferred]
# Force the Wayland/HDR compositor portal (wlr) to be used by default.
# This is what makes screensharing work properly in Hyprland.
default=xdg-desktop-portal-wlr
EOF

# --- Environment variables for Hyprland --------------------------------------
echo "==> Configuring environment variables for Hyprland"

mkdir -p "${HOME}/.config/environment.d"

cat >"${HOME}/.config/environment.d/hyprland-desktop.conf" <<'EOF'
# Make sure portals and apps see this as a Hyprland Wayland session
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_DESKTOP=Hyprland
EOF

echo "   - Created ${HOME}/.config/environment.d/hyprland-desktop.conf"
echo "     (You may need to log out and back in for this to take full effect.)"

# --- Enable and start user services ------------------------------------------
echo "==> Enabling and starting PipeWire and portal user services"

systemctl --user enable --now pipewire.service || true
systemctl --user enable --now pipewire-pulse.service || true
systemctl --user enable --now wireplumber.service || true
systemctl --user enable --now xdg-desktop-portal.service || true
systemctl --user enable --now xdg-desktop-portal-wlr.service || true

# --- Summary ------------------------------------------------------------------
echo
echo "============================================================"
echo "Hyprland screensharing setup complete."
echo
echo "Things to do next:"
echo "  1) Fully log out of your session and log back in,"
echo "     so the environment.d variables are applied."
echo "  2) Start Hyprland."
echo "  3) Test screensharing in e.g. Firefox/Chrome/Brave or Teams."
echo
echo "Debug tips:"
echo "  - systemctl --user status xdg-desktop-portal xdg-desktop-portal-wlr"
echo "  - echo \$XDG_CURRENT_DESKTOP"
echo "============================================================"
