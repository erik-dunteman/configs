set -o vi
export VIRTUAL_ENV_DISABLE_PROMPT=1
PS1='\n${VIRTUAL_ENV:+(${VIRTUAL_ENV##*/}) }\[\e[38;5;46m\]\w\[\e[0m\] \$ '
