#!/usr/bin/env bash

# =============================================================================
# MODERN DOTFILES SETUP SCRIPT
# =============================================================================
# This script sets up a complete development environment with:
# - Environment detection (personal/work)
# - Modern tool versions (mise instead of asdf)
# - Enhanced shell configuration
# - Automated macOS configuration
# - Comprehensive Elixir/Phoenix setup
# =============================================================================

set -euo pipefail

# Get the directory of the script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$SCRIPT_DIR"

# Source utilities
source "$SCRIPT_DIR/scripts/utils.sh"

# =============================================================================
# MAIN FUNCTIONS
# =============================================================================

check_prerequisites() {
  print_header "Checking Prerequisites"

  # Check if running on macOS
  if ! is_macos; then
    print_error "This script is designed for macOS only"
    exit 1
  fi

  # Check macOS version
  local os_version=$(get_os_version)
  print_info "macOS version: $os_version"

  # Check if we have internet connection
  if ! check_internet; then
    print_error "Internet connection required"
    exit 1
  fi

  # Check if we have sudo access
  if ! sudo -v; then
    print_error "Administrator privileges required"
    exit 1
  fi

  print_success "Prerequisites check passed"
}

show_installation_menu() {
  print_header "Installation Options"

  cat <<'EOF'
Choose your installation type:

1) 🚀 Full Setup (Recommended)
   • All components with environment detection
   • Homebrew + packages + development tools
   • Shell configuration + macOS optimization

2) 📦 Package Management Only
   • Homebrew + environment-specific packages
   • Mise + development tools

3) 🐚 Shell Configuration Only
   • Enhanced ZSH + modern tools
   • Aliases, functions, and completions

4) 🖥️  macOS Configuration Only
   • System preferences optimization
   • Developer-friendly settings

5) ❌ Exit

EOF

  print_question "Please select an option (1-5): "
  read -r -n 1 choice
  echo ""

  case $choice in
  1) install_full_setup ;;
  2) install_package_management ;;
  3) install_shell_config ;;
  4) install_macos_config ;;
  5) exit 0 ;;
  *)
    print_error "Invalid option. Please try again."
    show_installation_menu
    ;;
  esac
}

install_full_setup() {
  print_header "🚀 Full Setup Installation"

  # Create necessary directories
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.config"

  # Install in optimal order
  run_installer "homebrew" "📦 Installing Homebrew and packages"
  run_installer "mise" "🔧 Setting up mise and development tools"
  run_installer "shell" "🐚 Configuring enhanced shell"

  # Ask for macOS configuration
  ask_for_confirmation "Configure macOS system preferences?"
  if answer_is_yes; then
    run_installer "macos" "🖥️  Configuring macOS settings"
  fi

  setup_git_configuration
  migrate_bin_scripts
  create_useful_directories

  print_success "Full setup complete!"
  show_completion_message
}

install_package_management() {
  print_header "📦 Package Management Installation"

  run_installer "homebrew" "Installing Homebrew and packages"
  run_installer "mise" "Setting up mise and development tools"

  print_success "Package management setup complete!"
}

install_shell_config() {
  print_header "🐚 Shell Configuration Installation"

  run_installer "shell" "Configuring enhanced shell"

  print_success "Shell configuration complete!"
}

install_macos_config() {
  print_header "🖥️  macOS Configuration Installation"

  run_installer "macos" "Configuring macOS settings"

  print_success "macOS configuration complete!"
}

run_installer() {
  local installer="$1"
  local description="$2"
  local installer_script="$SCRIPT_DIR/installers/$installer.sh"

  if [[ ! -f "$installer_script" ]]; then
    print_error "Installer not found: $installer_script"
    return 1
  fi

  print_step "$description"

  if bash "$installer_script"; then
    print_success "$installer installation completed"
  else
    print_error "$installer installation failed"
    ask_for_confirmation "Continue with remaining installations?"
    if ! answer_is_yes; then
      exit 1
    fi
  fi
}

setup_git_configuration() {
  print_header "🔧 Setting up Git Configuration"

  # Link shared git configuration
  create_symlink "$DOTFILES_DIR/env/shared/.gitconfig" "$HOME/.gitconfig"

  # Setup environment-specific git configs
  local env=$(detect_environment)

  if [[ -f "$DOTFILES_DIR/env/$env/.gitconfig-$env" ]]; then
    create_symlink "$DOTFILES_DIR/env/$env/.gitconfig-$env" "$HOME/.gitconfig-$env"
  fi

  # Create git message templates
  if [[ -f "$DOTFILES_DIR/configs/git/gitmessage" ]]; then
    create_symlink "$DOTFILES_DIR/configs/git/gitmessage" "$HOME/.gitmessage"
  fi

  # Create global gitignore
  if [[ -f "$DOTFILES_DIR/configs/git/gitignore" ]]; then
    create_symlink "$DOTFILES_DIR/configs/git/gitignore" "$HOME/.gitignore"
  fi

  print_success "Git configuration complete"
}

migrate_bin_scripts() {
  print_header "🔧 Migrating Binary Scripts"

  # Create bin directory if it doesn't exist
  mkdir -p "$HOME/.local/bin"

  # Copy and link bin scripts
  if [[ -d "$DOTFILES_DIR/bin" ]]; then
    for script in "$DOTFILES_DIR/bin"/*; do
      if [[ -f "$script" ]]; then
        local script_name=$(basename "$script")
        create_symlink "$script" "$HOME/.local/bin/$script_name"
        chmod +x "$script"
      fi
    done
  fi

  print_success "Binary scripts migrated"
}

create_useful_directories() {
  print_header "📁 Creating Useful Directories"

  # Create development directories
  mkdir -p "$HOME/Code"
  mkdir -p "$HOME/Work"
  mkdir -p "$HOME/Screenshots"

  # Create .local structure
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share"
  mkdir -p "$HOME/.local/lib"

  # Create config directories
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.ssh"

  print_success "Useful directories created"
}

show_completion_message() {
  print_header "🎉 Installation Complete!"

  cat <<'EOF'
Your development environment is now set up! Here's what you can do next:

🚀 Get Started:
   • Open a new terminal window to activate the new configuration
   • Run 'sysinfo' to see your system information
   • Try 'project' to quickly switch between projects

🔧 Environment Detection:
   • Work in ~/Work/ for work environment
   • Work in ~/Code/ for personal environment
   • Environment automatically detected and configured

📖 Available Commands:
   • 'new-phoenix <name>' - Create new Phoenix LiveView project
   • 'new-elixir <name>' - Create new Elixir project
   • 'gcom feat "message"' - Conventional commits
   • 'port-kill <port>' - Kill process on port
   • 'weather <city>' - Check weather
   • 'note <name>' - Quick notes

🎨 Enhanced Tools:
   • Use 'fzf-files' for fuzzy file search
   • Use 'fzf-git' for interactive git log
   • Use 'recent' for recent directories
   • Use 'cleanup' for system cleanup

⚙️  Configuration:
   • Edit ~/.zshrc.local for personal customizations
   • Git configs automatically switch based on directory
   • Starship prompt shows current environment

📚 Documentation:
   • All aliases: run 'alias' command
   • All functions: check ~/.dotfiles/configs/shell/functions.sh
   • Git aliases: run 'git config --get-regexp alias'

EOF

  print_info "Installation log saved to: $HOME/.dotfiles_install.log"
  print_info "Dotfiles location: $DOTFILES_DIR"

  ask_for_confirmation "Would you like to restart your terminal now?"
  if answer_is_yes; then
    print_info "Please restart your terminal to activate all changes"
    exec "$SHELL" -l
  fi
}

cleanup_on_exit() {
  local exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    print_error "Installation failed with exit code: $exit_code"
    print_info "Check the log file: $HOME/.dotfiles_install.log"
  fi

  cleanup_temp_files
  exit $exit_code
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
  # Set up exit trap
  trap cleanup_on_exit EXIT

  # Check prerequisites
  check_prerequisites

  # Show installation menu
  show_installation_menu
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
