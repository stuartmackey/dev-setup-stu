# Source functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/share/shell/functions.sh"

#  This is the local directory that holds all shell scripts
SHELL_DIR="${HOME}/.config/shell"

echo "Set up local working folders"

mkdir -p ~/Working/personal
mkdir -p ~/Working/GoReport

echo "Set up cli tools"

install_tool aws aws-cli
install_tool sam aws-sam
install_tool aws-sso aws-sso

echo "Set up terminal applications"

install_tool tmux

echo "Set up scripts"

mkdir -p "${HOME}/.local/bin"
ln -sf "${SCRIPT_DIR}/bin/screenshot.sh" "${HOME}/.local/bin/screenshot.sh"
ln -sf "${SCRIPT_DIR}/bin/waybar-fan-control.sh" "${HOME}/.local/bin/waybar-fan-control.sh"
ln -sf "${SCRIPT_DIR}/bin/tmux_open.sh" "${HOME}/.local/bin/tmux_open.sh"

mkdir -p "${HOME}/.local/aliases"
ln -sf "${SCRIPT_DIR}/share/aliases/goreport_alias.sh" "${HOME}/.local/aliases/goreport_alias.sh"
ln -sf "${SCRIPT_DIR}/share/aliases/tmux_alias.sh" "${HOME}/.local/aliases/tmux_alias.sh"
ln -sf "${SCRIPT_DIR}/share/aliases/git_alias.sh" "${HOME}/.local/aliases/git_alias.sh"

echo "Set up shell profile"

# Create .bashrc.d if it doesn't exist
mkdir -p "${HOME}/.bashrc.d"

# Write a sourced file to source all aliases and add local bin to PATH
cat > "${HOME}/.bashrc.d/dev-setup-stu.sh" << 'EOF'
# dev-setup-stu: add ~/.local/bin to PATH
case ":${PATH}:" in
    *:"${HOME}/.local/bin":*) ;;
    *) export PATH="${HOME}/.local/bin:${PATH}" ;;
esac

# Source all aliases
for f in "${HOME}"/.local/aliases/*.sh; do
    [ -f "$f" ] && source "$f"
done
EOF

echo "Set up neovim plugins"
mkdir -p "${HOME}/.config/nvim/lua/plugins"
ln -sf "${SCRIPT_DIR}/share/nvim/plugins/disable-tabs.lua" "${HOME}/.config/nvim/lua/plugins/disable-tabs.lua"

echo "Set up keyboard"
"${SCRIPT_DIR}/bin/setup-keyboard.sh"

# Source the file from .bashrc if not already present
bashrc_file="${HOME}/.bashrc"
source_line="source ~/.bashrc.d/dev-setup-stu.sh"
if ! grep -qF "$source_line" "$bashrc_file" 2>/dev/null; then
    echo "" >> "$bashrc_file"
    echo "# dev-setup-stu aliases and PATH" >> "$bashrc_file"
    echo "$source_line" >> "$bashrc_file"
fi
