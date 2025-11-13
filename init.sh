
echo "Set up local working folders"

mkdir -p ~/Working/personal
mkdir -p ~/Working/GoReport

echo "Set up cli tools"

mise use -g aws-cli@latest
mise use -g aws-sam@latest
mise use -g aws-sso@latest

echo "Set up terminal applications"

mise use -g tmux@latest

