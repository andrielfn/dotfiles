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

# Source utilities first so show_usage/print_error are available during arg parsing
source "$SCRIPT_DIR/scripts/utils.sh"

show_usage() {
  cat << EOF
Usage: $0 [OPTIONS]

Setup dotfiles with machine-specific configuration.

OPTIONS:
  --machine-type=TYPE     Set machine type (personal|work) [default: personal]
  --work-dir=DIR          Set work directory name [default: Work]
  --full                  Run the full setup non-interactively (skip the menu)
  --help, -h              Show this help message

EXAMPLES:
  $0                                    # Interactive menu
  $0 --full                             # Full setup without the menu
  $0 --machine-type=work                # Work machine with ~/Work directory
  $0 --machine-type=work --work-dir=Company  # Work machine with ~/Company directory
EOF
}

# Default configuration
MACHINE_TYPE="personal"
WORK_DIR="Work"
RUN_FULL="false"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --machine-type=*)
      MACHINE_TYPE="${1#*=}"
      shift
      ;;
    --work-dir=*)
      WORK_DIR="${1#*=}"
      shift
      ;;
    --full)
      RUN_FULL="true"
      shift
      ;;
    --help|-h)
      show_usage
      exit 0
      ;;
    *)
      print_error "Unknown option: $1"
      show_usage
      exit 1
      ;;
  esac
done

# =============================================================================
# MACHINE SETUP FUNCTIONS
# =============================================================================

setup_machine_environment() {
  print_header "Setting up $MACHINE_TYPE machine environment"
  
  case "$MACHINE_TYPE" in
    personal)
      setup_personal_machine
      ;;
    work)
      setup_work_machine
      ;;
    *)
      print_error "Unknown machine type: $MACHINE_TYPE"
      print_info "Valid types: personal, work"
      exit 1
      ;;
  esac
}

setup_personal_machine() {
  print_step "Configuring personal machine"
  
  # Create Code directory for personal projects
  mkdir -p "$HOME/Code"
  print_success "Created ~/Code directory for personal projects"
  
  # Set personal environment as default
  print_success "Personal machine configuration complete"
}

setup_work_machine() {
  print_step "Configuring work machine"

  # Create work directory for work projects
  mkdir -p "$HOME/$WORK_DIR"
  print_success "Created ~/$WORK_DIR directory for work projects"

  if [[ "$WORK_DIR" != "Work" ]]; then
    print_warning "Custom work dir ~/$WORK_DIR: git's work identity applies under ~/Work/ only"
    print_info "Add an includeIf for ~/$WORK_DIR/ in config/git/gitconfig if needed."
  fi

  print_success "Work machine configuration complete"
}

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

  # Prime sudo once and keep it warm for the whole run so long steps (Homebrew
  # casks, macOS prefs) never stall on a hidden password prompt. When launched
  # via bootstrap.sh the timestamp is already cached, so this won't re-prompt.
  if ! keep_sudo_alive; then
    print_error "Administrator privileges required (is '$USER' an Administrator?)"
    exit 1
  fi

  print_success "Prerequisites check passed"
}

show_installation_menu() {
  print_header "Installation Options"

  echo "Choose your installation type:"
  echo ""
  echo "1) Full Setup (Recommended)"
  echo "2) Package Management Only"
  echo "3) Shell Configuration Only"
  echo "4) macOS Configuration Only"
  echo "5) Exit"
  echo ""

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

  # Setup machine environment first
  setup_machine_environment

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

  # Git configs (gitconfig, identities, allowed_signers) are linked by the
  # mapping system via the shell installer — no separate step needed.

  # 1Password bootstrap (setup-time only): SSH key, secrets, GitHub key registration
  ask_for_confirmation "Set up SSH key, secrets, and commit signing from 1Password?"
  if answer_is_yes; then
    run_installer "ssh" "🔑 Materializing SSH key from 1Password"
    run_installer "secrets" "🔐 Injecting secrets from 1Password"
    run_installer "git-signing" "✍️  Registering signing key on GitHub"
  fi

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
  # Note: ~/Work is created only on work machines (setup_work_machine), not here —
  # the work git identity (empty email) applies via includeIf in ~/Work/.
  mkdir -p "$HOME/Code"
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
  print_success "Installation Complete!"
  echo ""
  echo "Next steps:"
  echo "  • Run 'dotfiles help' for management commands"
  echo "  • Restart your terminal or run 'exec \$SHELL -l'"
  echo "  • Edit ~/.zshrc.local for personal customizations"
  echo ""
  print_info "Dotfiles: $DOTFILES_DIR"
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

  # Non-interactive full setup (used by bootstrap.sh), else interactive menu
  if [[ "$RUN_FULL" == "true" ]]; then
    install_full_setup
  else
    show_installation_menu
  fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
