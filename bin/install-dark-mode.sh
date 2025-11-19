#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Config – change these as needed
# -----------------------------
GTK_THEME="${GTK_THEME:-Adwaita-dark}"
ICON_THEME="${ICON_THEME:-Papirus-Dark}"
CURSOR_THEME="${CURSOR_THEME:-Bibata-Modern-Classic}"
CURSOR_SIZE="${CURSOR_SIZE:-24}"

# Simple Hyprland colour scheme (Nord-ish)
ACTIVE_BORDER="rgba(88c0d0ff)"
INACTIVE_BORDER="rgba(4c566aff)"
SHADOW_COLOR="rgba(00000099)"

# -----------------------------
# Helpers
# -----------------------------
log() { printf '[dark-theme] %s\n' "$*"; }

apply_gtk() {
  log "Applying GTK dark theme: $GTK_THEME"

  mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

  cat >"$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=${GTK_THEME}
gtk-icon-theme-name=${ICON_THEME}
gtk-cursor-theme-name=${CURSOR_THEME}
gtk-cursor-theme-size=${CURSOR_SIZE}
gtk-application-prefer-dark-theme=1
EOF

  cat >"$HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=${GTK_THEME}
gtk-icon-theme-name=${ICON_THEME}
gtk-cursor-theme-name=${CURSOR_THEME}
gtk-cursor-theme-size=${CURSOR_SIZE}
gtk-application-prefer-dark-theme=1
EOF
}

apply_cursor_env() {
  log "Setting cursor theme variables in this session"
  export XCURSOR_THEME="${CURSOR_THEME}"
  export XCURSOR_SIZE="${CURSOR_SIZE}"
}

apply_qt_hint() {
  # This just hints QT apps; they also often need qt5ct/qt6ct configured.
  log "Hinting QT to prefer dark palette (where supported)"
  mkdir -p "$HOME/.config"
  cat >"$HOME/.config/qt5ct.conf" <<EOF
[Appearance]
color_scheme=dark
EOF
}

main() {
  apply_gtk
  apply_cursor_env
  apply_qt_hint
  log "Done. You may need to restart some apps for the GTK/QT theme to fully apply."
}

main "$@"
