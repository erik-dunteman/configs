# Install after Ghostty's deferred integration initializes its SSH wrapper.
# Only plain `ssh modal-dev` in a local Ghostty tmux session is managed.
# Commands such as `ssh modal-dev uptime` retain normal SSH behavior.
_ghostty_tmux_install_ssh() {
    if [[ -n "$TMUX" && "$TMUX" == */ghostty,* && -z "$SSH_CONNECTION" ]]; then
        function ssh() {
            if (( $# == 1 )) && [[ "$1" == modal-dev ]]; then
                "$HOME/.local/bin/ghostty-tmux-ssh"
            elif [[ -n "$GHOSTTY_BIN_DIR" && -x "$GHOSTTY_BIN_DIR/ghostty" ]]; then
                "$GHOSTTY_BIN_DIR/ghostty" +ssh -- "$@"
            else
                command ssh "$@"
            fi
        }
    fi
    precmd_functions=(${precmd_functions:#_ghostty_tmux_install_ssh})
    unfunction _ghostty_tmux_install_ssh
}
precmd_functions+=(_ghostty_tmux_install_ssh)
