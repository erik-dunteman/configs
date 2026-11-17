# erikd devbox customizations — bash on devbox.
#
# This is NOT a full ~/.bashrc. It is a non-destructive overlay: append this
# block to the END of the devbox's existing ~/.bashrc. Everything else the
# devbox needs (PATH, aws-cli, nvm, cargo, oci autocomplete, ...)
# is provided by the box's default bashrc and is intentionally not tracked here.
#
#   cat shell/devbox.bashrc >> ~/.bashrc   # on devbox

set -o vi

# Prompt: blank line, venv name, then cwd in green (remote counterpart of the
# local zsh prompt, which is orange). VIRTUAL_ENV_DISABLE_PROMPT so we render
# the venv ourselves.
export VIRTUAL_ENV_DISABLE_PROMPT=1
export VISUAL=nvim
PS1='\n${VIRTUAL_ENV:+(${VIRTUAL_ENV##*/}) }\[\e[38;5;34m\]\w\[\e[0m\] \$ '

alias yolo='claude --dangerously-skip-permissions'

# Atuin history search (install Atuin and copy atuin/config.toml first).
if [ -f "$HOME/.atuin/bin/env" ]; then
    . "$HOME/.atuin/bin/env"
fi
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init bash)"
fi
