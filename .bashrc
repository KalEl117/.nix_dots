#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
# --- Git Aliases ---

# Schneller Statuscheck
alias gs="git status -sb" # Kompakt und übersichtlich

# Alles hinzufügen, committen und direkt pushen mit einem Befehl
# Nutzung: gcap "Mein commit text"
gcap() {
    git add .
    git commit -m "$1"
    git push
}

# Der Klassiker: add und commit in einem Rutsh (ohne automatischen Push)
# Nutzung: gc "Fix: fehler behoben"
gc() {
    git add .
    git commit -m "$1"
}

# Standard-Befehle abgekürzt
alias gp="git push"
alias gl="git pull"
alias gd="git diff"

# Schöne, kompakte Log-Ansicht als Baum (perfekt fürs Terminal)
alias glog="git log --graph --oneline --decorate --all"

alias ls='ls --color=auto'
alias ll='ls -al'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ff='fastfetch'
alias nrs='sudo nixos-rebuild switch'
alias nixconf='sudoedit /etc/nixos/configuration.nix'
alias v='nvim'
alias gitupdate='~/.dotfiles/sync_dotfiles.sh'
alias ping='ping -c3'
alias grep='grep --color=auto'
PS1="\[\e[1;36m\]╭─ \[\e[1;34m\]\w \[\e[0m\]\n\[\e[1;36m\]╰─\[\e[1;32m\]❯ \[\e[0m\]"

HISTFILE=~/.bash_history
HISTSIZE=10000
SAVEHIST=10000

export PROMPT_COMMAND='history -a; history -r'

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'
eval "$(zoxide init bash)"
