# Sublime as default editor.
export BUNDLER_EDITOR="subl"
export GEM_EDITOR="subl"
export EDITOR="subl -w"
export VISUAL="$EDITOR"
export BAT_THEME="TwoDark"
# export FZF_DEFAULT_OPTS="--bind='enter:execute(subl {})+abort'"

export HISTFILE="$HOME/.zsh_history"
export HISTCONTROL="ignoreboth:erasedups" # Erase duplicates in history
export HISTSIZE=10000 # Store 10k history entries

export HOMEBREW_AUTO_UPDATE_SECS=600000

# PATH
export GOPATH="$HOME/code/go"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="./bin:$PATH"
export PATH="$PATH:/usr/local/opt/mongodb@3.0/bin"
export PATH="$GOPATH/bin:$PATH"
export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"

export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home"

# IEx history
# https://hexdocs.pm/iex/IEx.html#module-shell-history
export ERL_AFLAGS="-kernel shell_history enabled"

if [ $ITERM_SESSION_ID ]; then
  export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"$PROMPT_COMMAND";
fi
