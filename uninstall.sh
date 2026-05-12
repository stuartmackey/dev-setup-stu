#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Remove symlinked scripts"
rm -f "${HOME}/.local/bin/screenshot.sh"
rm -f "${HOME}/.local/bin/waybar-fan-control.sh"
rm -f "${HOME}/.local/bin/tmux_open.sh"
# Remove .local/bin if empty
rmdir "${HOME}/.local/bin" 2>/dev/null || true

echo "Remove neovim plugin config"
rm -f "${HOME}/.config/nvim/lua/plugins/disable-tabs.lua"

echo "Remove symlinked aliases"
rm -f "${HOME}/.local/aliases/goreport_alias.sh"
rm -f "${HOME}/.local/aliases/tmux_alias.sh"
rm -f "${HOME}/.local/aliases/git_alias.sh"
# Remove .local/aliases if empty
rmdir "${HOME}/.local/aliases" 2>/dev/null || true

echo "Remove shell profile configuration"
rm -f "${HOME}/.bashrc.d/dev-setup-stu.sh"
# Remove .bashrc.d if empty
rmdir "${HOME}/.bashrc.d" 2>/dev/null || true

echo "Revert keyboard config"
"${SCRIPT_DIR}/bin/setup-keyboard.sh" --revert

echo "Remove sourcing line from .bashrc"
bashrc_file="${HOME}/.bashrc"
source_line="source ~/.bashrc.d/dev-setup-stu.sh"
comment_line="# dev-setup-stu aliases and PATH"
if grep -qF "$source_line" "$bashrc_file" 2>/dev/null; then
  # Use a temp file to strip the two lines
  tmp=$(mktemp)
  grep -vF "$source_line" "$bashrc_file" | grep -vF "$comment_line" > "$tmp"
  # Clean up trailing blank lines
  awk 'NF { blank=0 } /^$/ { blank++ } blank<=1' "$tmp" > "${tmp}2" && mv "${tmp}2" "$tmp"
  mv "$tmp" "$bashrc_file"
fi

echo "Note: the following were NOT removed (may contain personal data):"
echo "  - ~/Working/personal"
echo "  - ~/Working/GoReport"
echo ""
echo "Note: CLI tools installed via 'mise' were NOT uninstalled."
echo "  To remove them manually:"
echo "    mise uninstall aws-cli@latest"
echo "    mise uninstall aws-sam@latest"
echo "    mise uninstall aws-sso@latest"
echo "    mise uninstall tmux@latest"
echo ""
echo "Done."
