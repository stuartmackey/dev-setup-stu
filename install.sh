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
ln -sf "${SCRIPT_DIR}/bin/tmux_open.sh" "${HOME}/.local/bin/tmux_open.sh"
ln -sf "${SCRIPT_DIR}/bin/screenshot.sh" "${HOME}/.local/bin/screenshot.sh"
