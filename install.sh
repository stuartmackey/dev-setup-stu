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
ln -sf "${HOME}/Working/personal/dev-setup-stu/bin/tmux_open.sh" "${HOME}/.local/bin/tmux_open.sh"

mkdir -p "${HOME}/.local/aliases"
ln -sf "${HOME}/Working/personal/dev-setup-stu/share/aliases/goreport_alias.sh" "${HOME}/.local/aliases/goreport_alias.sh"
ln -sf "${HOME}/Working/personal/dev-setup-stu/share/aliases/tmux_alias.sh" "${HOME}/.local/aliases/tmux_alias.sh"
ln -sf "${HOME}/Working/personal/dev-setup-stu/share/aliases/git_alias.sh" "${HOME}/.local/aliases/git_alias.sh"
