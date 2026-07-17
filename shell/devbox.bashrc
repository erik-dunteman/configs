# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc
# >>> modal initialize >>>

# --- erikd local-parity config ---
export PATH="$HOME/.local/bin:$PATH"
set -o vi
export VIRTUAL_ENV_DISABLE_PROMPT=1
PS1='\n${VIRTUAL_ENV:+(${VIRTUAL_ENV##*/}) }\[\e[38;5;34m\]\w\[\e[0m\] \$ '
alias yolo='claude --dangerously-skip-permissions'
# --- end erikd ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. "$HOME/.cargo/env"
export PATH=/usr/local/aws-cli/v2/current/bin:$PATH
# AWS authenticator for accessing EKS clusters
export PATH=$PATH:$HOME/.aws/bin:$HOME/.pulumi/bin

export PATH=/home/ec2-user/bin:$PATH

[[ -e "/home/ec2-user/lib/oracle-cli/lib/python3.9/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/home/ec2-user/lib/oracle-cli/lib/python3.9/site-packages/oci_cli/bin/oci_autocomplete.sh"
export PATH=$PATH:$HOME/lib/oracle-cli/bin
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
# cd /home/ec2-user/modal
# source .venv/bin/activate
# <<< modal initialize <<<

# add S2 to the PATH
export PATH=$PATH:/home/ec2-user/.s2/bin
