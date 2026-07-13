#!/usr/bin/env bash

# Homebrew installer with environment-specific package management
# This script installs Homebrew and manages packages based on the current environment

source "$(dirname "$0")/../scripts/utils.sh"

# Environment detection function is now in utils.sh

install_homebrew() {
  print_in_yellow "=> Installing Homebrew...\n"

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
  local dotfiles_dir="$1"

  print_in_yellow "=> Installing packages from Brewfile\n"

  if [[ -f "$dotfiles_dir/Brewfile" ]]; then
    print_info "On a fresh Mac this can take several minutes — downloads run in parallel and progress appears below. Please don't cancel."
    # Skip the redundant auto-update (Homebrew was just installed/updated) and
    # quiet env hints so the download/install progress is the only output.
    HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1 \
      brew bundle --file="$dotfiles_dir/Brewfile"
  else
    print_warning "Brewfile not found"
  fi

  # Cleanup
  brew cleanup
  brew doctor

  print_success "All packages installed successfully"
}

main() {
  local dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

  # Install Homebrew
  install_homebrew

  # Ask for confirmation before installing packages
  ask_for_confirmation "Install packages from Brewfile?"
  if answer_is_yes; then
    install_packages "$dotfiles_dir"
  else
    print_warning "Skipped package installation"
  fi

  print_success "Homebrew setup complete!\n"
}

main "$@"
