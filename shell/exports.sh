# =============================================================================
# SHELL-SPECIFIC EXPORTS AND LOGIC
# =============================================================================
# This file contains PATH manipulation and shell-specific logic
# Simple environment variables have been moved to env/shared/env-shared

# PATH configuration (depends on DOTFILES_DIR and has complex logic)
export PATH="/usr/local/sbin:$PATH"
export PATH="./bin:$PATH"

# Mise configuration
export PATH="$HOME/.local/share/mise/shims:$PATH"

# PostgreSQL configuration
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"

# Setup PNPM
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# User-local paths take priority over everything above
export PATH="$DOTFILES_DIR/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
