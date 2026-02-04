# =============================================================================
# SHELL INITIALIZATION
# =============================================================================

# Environment detection
detect_environment() {
  if [[ -d "$HOME/Work" ]] || [[ -d "$HOME/work" ]]; then
    echo "work"
  else
    echo "personal"
  fi
}

# Load environment-specific configuration
load_env_config() {
  local env=$(detect_environment)
  local dotfiles_path="$HOME/.dotfiles"

  # Load shared public environment variables first
  if [[ -f "$dotfiles_path/env/shared/env-shared" ]]; then
    source "$dotfiles_path/env/shared/env-shared"
  fi

  # Load shared secrets (not tracked by git)
  if [[ -f "$dotfiles_path/env/shared/env-secrets" ]]; then
    source "$dotfiles_path/env/shared/env-secrets"
  fi

  # Load environment-specific public variables
  if [[ -f "$dotfiles_path/env/$env/env-$env" ]]; then
    source "$dotfiles_path/env/$env/env-$env"
  fi

  # Load environment-specific secrets (not tracked by git)
  if [[ -f "$dotfiles_path/env/$env/env-secrets" ]]; then
    source "$dotfiles_path/env/$env/env-secrets"
  fi
}

# Initialize shell environment
init_shell() {
  # Load environment-specific configuration
  load_env_config

  # Initialize Homebrew environment if available
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  # Initialize Oh My Zsh if available
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    export ZSH="$HOME/.oh-my-zsh"
    source "$ZSH/oh-my-zsh.sh"
  fi

  # Initialize tools if available
  if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
  fi

  if command -v zoxide &>/dev/null && [[ "$CLAUDECODE" != "1" ]]; then
    eval "$(zoxide init --cmd cd zsh)"
  fi

  if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
  fi

  if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
  fi

  if command -v fzf &>/dev/null; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  fi

  if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh)"
  fi

  # SSH agent — start if not running, load default keys with 4h timeout
  if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add --apple-use-keychain -t 14400 ~/.ssh/id_ed25519 2>/dev/null
  fi

  # Initialize 1Password CLI if enabled and available
  # if [[ "$ENABLE_1PASSWORD_CLI" == "true" ]] && command -v op &>/dev/null; then
  #   eval "$(op signin)"
  # fi
}

# Run initialization
init_shell
