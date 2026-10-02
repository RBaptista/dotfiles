# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# CachyOS ships oh-my-zsh + p10k + plugins as one config. On plain Arch,
# load the same prompt and plugins directly (install.sh installs them).
if [[ -r /usr/share/cachyos-zsh-config/cachyos-config.zsh ]]; then
  source /usr/share/cachyos-zsh-config/cachyos-config.zsh
else
  autoload -Uz compinit && compinit
  for f in \
    /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
    [[ -r $f ]] && source $f
  done
  unset f
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias vim='nvim'
alias cls='clear'
export PATH=~/.npm-global/bin:$PATH
alias ll='ls -a'

# Add JBang to environment
alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"
#export JAVA_HOME=$HOME/.jbang/currentjdk
export JAVA_HOME=/usr/lib/jvm/default
export PATH="$HOME/.local/bin:$PATH"

# Type 'y' to open yazi, and when you quit, it stays in that directory
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
