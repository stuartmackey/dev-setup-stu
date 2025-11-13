#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    work_items=`find ~/Working/GoReport -maxdepth 1 -mindepth 1 -type d `
    personal_items=`find ~/Working/personal -maxdepth 1 -mindepth 1 -type d `
    selected=`echo -e "$work_items\n$personal_items" | fzf`
fi

if [ -z "$selected" ]
then
      exit 0
fi

tmux_session_name=`basename $selected`

tmux switch-client -t $tmux_session_name
if [[ $? -eq 0 ]]; then
    exit 0
fi

tmux new-session -c $selected -d -s $tmux_session_name && tmux switch-client -t $tmux_session_name || tmux new -c $selected -A -s $tmux_session_name

