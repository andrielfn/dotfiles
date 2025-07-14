#!/usr/bin/env bash

# Shell installer for enhanced ZSH configuration
# This script sets up ZSH with modern completions and configurations

source "$(dirname "$0")/../scripts/utils.sh"
source "$(dirname "$0")/../scripts/config.sh"

# Helper function to ensure brew is in PATH
ensure_brew_in_path() {
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# Helper function to install tools via brew
install_via_brew() {
  local tool="$1"
  local package="${2:-$tool}"

  if ! command -v "$tool" &>/dev/null; then
    print_warning "$tool not installed. Installing via Homebrew..."
    ensure_brew_in_path
    brew install "$package"
  fi
}

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

setup_oh_my_zsh() {
  print_in_yellow "=> Setting up Oh My Zsh..."

  # Check if Oh My Zsh is already installed
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh is already installed"
    return 0
  fi

  # Install Oh My Zsh non-interactively
  print_in_blue "Installing Oh My Zsh..."
  export RUNZSH=no
  export CHSH=no
  export KEEP_ZSHRC=yes

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh installed successfully"
  else
    print_error "Failed to install Oh My Zsh"
    return 1
  fi
}

setup_shell_directories() {
  print_in_yellow "=> Setting up shell directories..."

  # Create ZSH cache directory
  mkdir -p "$HOME/.zsh/cache"
  print_success "Created ZSH cache directory"

  # Create completions directory
  mkdir -p "$HOME/.zsh/completions"
  print_success "Created ZSH completions directory"

  print_success "Shell directories setup complete"
}

setup_completions() {
  print_in_yellow "=> Setting up shell completions..."

  # Download git completion and prompt scripts
  local git_completion_url="https://raw.githubusercontent.com/git/git/master/contrib/completion"
  local completions=(
    "git-completion.bash"
    "git-prompt.sh"
  )

  for completion in "${completions[@]}"; do
    if [[ ! -f "$HOME/.zsh/$completion" ]]; then
      curl -o "$HOME/.zsh/$completion" "$git_completion_url/$completion"
      print_success "Downloaded $completion"
    fi
  done

  print_success "Shell completions setup complete"
}

setup_starship() {
  print_in_yellow "=> Setting up Starship prompt..."

  install_via_brew "starship"

  print_success "Starship setup complete"
}

setup_zoxide() {
  print_in_yellow "=> Setting up zoxide (smart cd)..."

  install_via_brew "zoxide"

  print_success "zoxide setup complete"
}

setup_fzf() {
  print_in_yellow "=> Setting up FZF (fuzzy finder)..."

  install_via_brew "fzf"

  # Install FZF key bindings and completion
  ensure_brew_in_path
  local fzf_install_script="$(brew --prefix)/opt/fzf/install"
  if [[ -f "$fzf_install_script" ]]; then
    yes | "$fzf_install_script"
  fi

  print_success "FZF setup complete"
}

main() {
  local dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

  # Create necessary directories
  mkdir -p "$HOME/.local/bin"

  # Setup ZSH
  setup_zsh

  # Setup Oh My Zsh
  setup_oh_my_zsh

  # Setup shell configurations using mapping system
  setup_configurations "$dotfiles_dir"

  # Create additional shell directories
  setup_shell_directories

  # Setup completions
  setup_completions

  # Setup modern tools
  setup_starship
  setup_zoxide
  setup_fzf

  print_success "Shell setup complete!"
  print_in_blue "Please restart your terminal or run: source ~/.zshrc"
}

main "$@"
