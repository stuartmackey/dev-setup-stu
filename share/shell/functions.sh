install_tool() {
    local binary_name=$1
    local tool_name=$2
    
    if ! command -v "$binary_name" &> /dev/null; then
        mise use -g "${tool_name}@latest"
    fi
}
