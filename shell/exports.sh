# =============================================================================
# SHELL-SPECIFIC EXPORTS AND LOGIC
# =============================================================================
# This file contains PATH manipulation and shell-specific logic
# Simple environment variables have been moved to env/shared/env-shared

# PATH configuration (depends on DOTFILES_DIR and has complex logic)
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="$DOTFILES_DIR/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="./bin:$PATH"

# Mise configuration
export PATH="$HOME/.local/share/mise/shims:$PATH"

# PostgreSQL configuration (user-specific, often needs customization)
# export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Shell-specific settings
export DISABLE_AUTO_TITLE="true"

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
