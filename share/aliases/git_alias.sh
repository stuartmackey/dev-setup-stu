# Git aliases
alias git-default='git checkout $(git symbolic-ref --short refs/remotes/origin/HEAD | sed '"'"'s@origin/@@'"'"')'
alias gd='git-default'