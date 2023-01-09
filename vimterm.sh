#!/usr/bin/env bash

echo "asdf${@}asdf"
if echo "${@}" | grep "^tmux" &>/dev/null; then
	"${@}"
	exit
fi

# initial checks

if ! command -v tmux &>/dev/null; then
	echo "tmux not found, attempting to start SHELL instead"

	if [ -v $SHELL ]; then
		$SHELL "$@"
		exit
	fi

	echo "SHELL not set, exiting. Press any key (so you had a chance to see this)"
	read
	exit 1
fi

tmuxConfLocation=/tmp/tmux-vimterm/vimterm.conf

if [ ! -d /tmp/tmux-vimterm ]; then
	if ! mkdir /tmp/tmux-vimterm; then
		echo "could not make tmp directory"
		echo "press any key"
		read
		exit 1
	fi
fi

cat >$tmuxConfLocation <<EOL
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
setw -g xterm-keys on
set -s escape-time 10
set -sg repeat-time 600
set -s focus-events on
set -g mouse on
set -q -g status-utf8 on
setw -q -g utf8 on
setw -g history-limit 50000000
tmux_conf_copy_to_os_clipboard=true
set -g status-keys vi
set -g mode-keys vi
set -g status-position bottom
set -g status off
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy"
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy"

bind-key -T root M-z copy-mode

bind-key -T copy-mode-vi Tab run-shell "nvim --server $NVIM_LISTEN_ADDRESS --remote-send '<C-S-n><Tab>'"
bind-key -T copy-mode-vi S-Tab run-shell "nvim --server $NVIM_LISTEN_ADDRESS --remote-send '<C-S-n><S-Tab>'"

bind-key -T root WheelUpPane \
    if-shell -Ft= '#{?mouse_any_flag,1,#{pane_in_mode}}' \
    'send -Mt=' 'if-shell -t= "#{?alternate_on,true,false} || \
        echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
    "send -t= Up Up Up" "copy-mode -t="'
bind-key -T root WheelDownPane \
    if-shell -Ft= '#{?pane_in_mode,1,#{mouse_any_flag}}' \
    'send -Mt=' 'if-shell -t= "#{?alternate_on,true,false} || \
        echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
    "send -t= Down Down Down" "send -Mt="'
bind -n MouseDrag1Pane \
    if -Ft= '#{mouse_any_flag}' \
    'if -Ft= \"#{pane_in_mode}\" \
    \"copy-mode -eM\" \
    \"send-keys -M\"' \
    'copy-mode -eM'
EOL

session=0

TMUX_ARGS=(-S /tmp/tmux-vimterm/vimterm -L vimterm)

if tmux ${TMUX_ARGS[@]} ls &>/dev/null; then
	# close all unattached first
	IFS=$'\n'
	currentSessions=($(tmux ${TMUX_ARGS[@]} ls))
	for s in ${currentSessions[@]}; do
		if echo $s | grep attached &>/dev/null; then
			continue
		fi

		tmux ${TMUX_ARGS[@]} kill-session -t $(echo $s | cut -d ":" -f1)
	done

	currentSessions=($(tmux ${TMUX_ARGS[@]} ls))
	for s in ${currentSessions[@]}; do
		if echo "$s" | grep -i "vimterm[0-9]" &>/dev/null; then
			if tmux ${TMUX_ARGS[@]} -f $tmuxConfLocation ls -F '#{session_name}' | grep "vimterm$session" &>/dev/null; then
				let session++
			else
				break
			fi
		fi
	done
fi

ARGS=$(echo "$@" | sed 's/\-c//')
if [ ! -z "$ARGS" ]; then
	tmux ${TMUX_ARGS[@]} -f $tmuxConfLocation new-session -d -s vimterm$session "$ARGS"
else
	tmux ${TMUX_ARGS[@]} -f $tmuxConfLocation new-session -d -s vimterm$session
fi

# if you're already in a tmux session, this isn't quite a nested tmux so we unset this so tmux doesn't complain about it
unset TMUX

tmux ${TMUX_ARGS[@]} a -t vimterm$session
