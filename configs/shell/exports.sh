# Editor configuration
export EDITOR="zed -w"
export VISUAL="$EDITOR"

# Shell history configuration
export HISTFILE="$HOME/.zsh_history"
export HISTCONTROL="ignoreboth:erasedups"
export HISTSIZE=100000000
export SAVEHIST=100000000
export HISTFILESIZE=100000000
export HIST_STAMPS='dd/mm/yyyy'

# Homebrew configuration
export HOMEBREW_AUTO_UPDATE_SECS=600000
export HOMEBREW_NO_ANALYTICS=1

# PATH configuration
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="./bin:$PATH"

# Mise configuration
export PATH="$HOME/.local/share/mise/shims:$PATH"

# PostgreSQL configuration
# export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Language-specific configuration
export ERL_AFLAGS="-kernel shell_history enabled"
export ELIXIR_EDITOR="zed +__LINE__ __FILE__"

# Tool configurations
export STARSHIP_CONFIG="$HOME/.starship.toml"
export GPG_TTY="$(tty)"
export BAT_THEME="TwoDark"

# Disable auto title
export DISABLE_AUTO_TITLE="true"

# FZF configuration with modern colors
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
  --color=fg:-1,fg+:#9769dc,bg:-1,bg+:-1
  --color=hl:#9769dc,hl+:#9769dc,info:#85888c,marker:#f2590c
  --color=prompt:#7a3e9d,spinner:#9769dc,pointer:#9769dc,header:#85888c
  --color=selected-bg:#9769dc
  --color=label:#85888c,query:#5c6066
  --preview-window="border-rounded" --prompt="❯ " --marker="❯" --pointer="▸"
  --separator="━" --scrollbar="┃" --border="rounded"
  --border-label="╢ FZF ╟" --border-label-pos="3:top"
  --preview="bat --color=always --style=header,grid --line-range :300 {}"
'

# Zoxide configuration
export _ZO_DATA_DIR="$HOME/.local/share/zoxide"
export _ZO_ECHO=1

# Development tool configurations
export DFT_DISPLAY=inline
export DFT_TAB_WIDTH=2

# Setup PNPM
export PNPM_HOME="/Users/andriel/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Tab title function
precmd() {
  echo -ne "\e]1;${PWD##*/}\a"
}
