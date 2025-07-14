#!/usr/bin/env bash

# Shell installer for enhanced ZSH configuration
# This script sets up ZSH with modern completions and configurations

source "$(dirname "$0")/../scripts/utils.sh"

setup_zsh() {
  print_in_yellow "=> Setting up ZSH as default shell..."

  # Check if ZSH is installed
  if ! command -v zsh &>/dev/null; then
    print_error "ZSH is not installed. Please install it first with: brew install zsh"
    return 1
  fi

  # Set ZSH as default shell if not already
  if [[ "$SHELL" != *"zsh"* ]]; then
    print_in_blue "Setting ZSH as default shell..."
    chsh -s "$(which zsh)"
    print_success "ZSH set as default shell"
  else
    print_success "ZSH is already the default shell"
  fi
}

setup_shell_configs() {
  local dotfiles_dir="$1"

  print_in_yellow "=> Setting up shell configurations..."

  # Backup existing configurations
  for config in ~/.zshrc ~/.zprofile ~/.zshenv; do
    if [[ -f "$config" && ! -L "$config" ]]; then
      mv "$config" "$config.backup.$(date +%Y%m%d-%H%M%S)"
      print_warning "Backed up existing $config"
    fi
  done

  # Link new configurations
  ln -sf "$dotfiles_dir/configs/shell/zshrc" "$HOME/.zshrc"
  print_success "Linked .zshrc"

  # Create dotfiles symlink
  ln -sf "$dotfiles_dir" "$HOME/.dotfiles"
  print_success "Created .dotfiles symlink"

  # Create ZSH cache directory
  mkdir -p "$HOME/.zsh/cache"
  print_success "Created ZSH cache directory"
}

setup_completions() {
  print_in_yellow "=> Setting up shell completions..."

  # Create completions directory
  mkdir -p "$HOME/.zsh/completions"

  # Download git completion if not exists
  if [[ ! -f "$HOME/.zsh/git-completion.bash" ]]; then
    curl -o "$HOME/.zsh/git-completion.bash" \
      https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
    print_success "Downloaded git completion"
  fi

  # Download git prompt if not exists
  if [[ ! -f "$HOME/.zsh/git-prompt.sh" ]]; then
    curl -o "$HOME/.zsh/git-prompt.sh" \
      https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
    print_success "Downloaded git prompt"
  fi

  print_success "Shell completions setup complete"
}

setup_starship() {
  print_in_yellow "=> Setting up Starship prompt..."

  if ! command -v starship &>/dev/null; then
    print_warning "Starship not installed. Installing via Homebrew..."
    # Ensure brew is in PATH
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    brew install starship
  fi

  # Note: Starship configuration is now handled by the centralized config system
  print_success "Starship setup complete"
}

setup_zoxide() {
  print_in_yellow "=> Setting up zoxide (smart cd)..."

  if ! command -v zoxide &>/dev/null; then
    print_warning "zoxide not installed. Installing via Homebrew..."
    # Ensure brew is in PATH
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    brew install zoxide
  fi

  print_success "zoxide setup complete"
}

setup_fzf() {
  print_in_yellow "=> Setting up FZF (fuzzy finder)..."

  if ! command -v fzf &>/dev/null; then
    print_warning "FZF not installed. Installing via Homebrew..."
    # Ensure brew is in PATH
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    brew install fzf
  fi

  # Install FZF key bindings and completion
  if [[ -f "/opt/homebrew/opt/fzf/install" ]]; then
    yes | /opt/homebrew/opt/fzf/install
  elif [[ -f "/usr/local/opt/fzf/install" ]]; then
    yes | /usr/local/opt/fzf/install
  fi

  print_success "FZF setup complete"
}

create_environment_indicator() {
  print_in_yellow "=> Creating environment indicator..."

  # Create script to detect and set environment
  cat >"$HOME/.local/bin/set-env-indicator" <<'EOF'
#!/usr/bin/env bash
# Script to set environment indicator for prompt

# Check for work directories in home
if [[ -d "$HOME/Work" ]] || [[ -d "$HOME/work" ]]; then
    export DOTFILES_ENV="WORK"
else
    export DOTFILES_ENV="PERSONAL"
fi
EOF

  chmod +x "$HOME/.local/bin/set-env-indicator"
  print_success "Environment indicator created"
}

main() {
  local dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

  # Create necessary directories
  mkdir -p "$HOME/.local/bin"

  # Setup ZSH
  setup_zsh

  # Setup shell configurations
  setup_shell_configs "$dotfiles_dir"

  # Setup completions
  setup_completions

  # Setup modern tools
  setup_starship
  setup_zoxide
  setup_fzf

  # Create environment indicator
  create_environment_indicator

  # Setup configurations
  setup_configurations "$dotfiles_dir"

  print_success "Shell setup complete!"
  print_in_blue "Please restart your terminal or run: source ~/.zshrc"
}

main "$@"
