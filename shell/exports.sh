# Sublime as default editor.
export BUNDLER_EDITOR="subl"
export GEM_EDITOR="subl"
export EDITOR="subl -w -n"
export VISUAL="$EDITOR"
export BAT_THEME="TwoDark"

export HISTFILE="$HOME/.zsh_history"
export HISTCONTROL="ignoreboth:erasedups" # Erase duplicates in history
export HISTSIZE=10000 # Store 10k history entries

export HOMEBREW_AUTO_UPDATE_SECS=600000

# PATH
export GOPATH="$HOME/Code/go"
export PATH="$HOME/.bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="./bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

# IEx history
# https://hexdocs.pm/iex/IEx.html#module-shell-history
export ERL_AFLAGS="-kernel shell_history enabled"

export STARSHIP_CONFIG=~/.starship.toml
export GPG_TTY=$(tty)
export PATH="$(yarn global bin):$PATH"

DISABLE_AUTO_TITLE="true"

precmd() {
  # sets the tab title to current dir
  echo -ne "\e]1;${PWD##*/}\a"
}
