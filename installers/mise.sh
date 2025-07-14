#!/usr/bin/env bash

# Mise installer for development tool version management
# This script installs mise and configures it for Elixir/Erlang development

source "$(dirname "$0")/../scripts/utils.sh"

install_mise() {
  print_in_yellow "=> Installing mise (development tool version manager)..."

  if command -v mise &>/dev/null; then
    print_success "mise already installed"
    return 0
  fi

  # Install mise using the official installer
  curl https://mise.run | sh

  # Add mise to PATH for current session
  export PATH="$HOME/.local/bin:$PATH"

  print_success "mise installed successfully"
}

setup_mise_config() {
  local dotfiles_dir="$1"

  print_in_yellow "=> Setting up mise configuration..."

  # Create mise config directory
  mkdir -p "$HOME/.config/mise"

  # Note: mise configuration is now handled by the centralized config system
  print_success "mise configuration will be linked by the centralized config system"

  print_success "mise configuration complete"
}

install_development_tools() {
  print_in_yellow "=> Setting up mise for development tools..."

  # Activate mise in current session
  eval "$(mise activate bash)"

  # Install tools defined in global config (if any)
  mise install

  # Verify mise is working
  print_in_blue "Verifying mise installation..."
  mise list

  print_success "Mise setup completed - you can now install tools manually as needed"
}

main() {
  local dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

  # Install mise
  install_mise

  # Setup configuration
  setup_mise_config "$dotfiles_dir"

  # Setup development tools
  install_development_tools

  print_success "mise setup complete!\n"
}

main "$@"
