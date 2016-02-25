# Editor
export EDITOR="subl -w"

# Git
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM=auto

# History
export HISTCONTROL="ignoreboth:erasedups" # Erase duplicates in history
export HISTSIZE=10000 # Store 10k history entries
shopt -s histappend # Append to the history file when exiting instead of overwriting it

# Customize the terminal input line
prompt() {
  # PS1="${CYAN}\w ${MAGENTA}(\$(rb-version))${GREEN}\$(__git_ps1)\n${RED}$ ${NORMAL}"
  PS1="${CYAN}\w${GREEN}\$(__git_ps1) ${RED}$ ${NORMAL}"
}

PROMPT_COMMAND=prompt

# Rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# PATH
export GOPATH="$HOME/code/go"
export PATH="$HOME/.bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"

# Autojump
[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f ~/.dotfiles/bash/git-completion.sh ]; then
  complete -o default -o nospace -F _git g;
fi;
