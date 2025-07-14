#!/usr/bin/env bash

# Homebrew installer with environment-specific package management
# This script installs Homebrew and manages packages based on the current environment

source "$(dirname "$0")/../scripts/utils.sh"

# Environment detection function is now in utils.sh

install_homebrew() {
  print_in_yellow "=> Installing Homebrew..."

  if command -v brew &>/dev/null; then
    print_success "Homebrew already installed"
    brew update
    return 0
  fi

  # Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  print_success "Homebrew installed successfully"
}

install_packages() {
  local env="$1"
  local dotfiles_dir="$2"

  print_in_yellow "=> Installing packages for environment: $env"

  # Install shared packages first
  if [[ -f "$dotfiles_dir/env/shared/Brewfile" ]]; then
    print_in_blue "Installing shared packages..."
    brew bundle --file="$dotfiles_dir/env/shared/Brewfile"
  fi

  # Install environment-specific packages
  if [[ -f "$dotfiles_dir/env/$env/Brewfile" ]]; then
    print_in_blue "Installing $env-specific packages..."
    brew bundle --file="$dotfiles_dir/env/$env/Brewfile"
  fi

  # Cleanup
  brew cleanup
  brew doctor

  print_success "All packages installed successfully"
}

main() {
  local current_env=$(detect_environment)
  local dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

  print_in_yellow "Detected environment: $current_env\n"

  # Install Homebrew
  install_homebrew

  # Ask for confirmation before installing packages
  ask_for_confirmation "Install packages for $current_env environment?"
  if answer_is_yes; then
    install_packages "$current_env" "$dotfiles_dir"
  else
    print_warning "Skipped package installation"
  fi

  print_success "Homebrew setup complete!\n"
}

main "$@"
