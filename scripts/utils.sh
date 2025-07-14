#!/usr/bin/env bash

# =============================================================================
# UTILITY FUNCTIONS FOR DOTFILES SETUP
# =============================================================================

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# =============================================================================
# PRINT FUNCTIONS
# =============================================================================

print_in_color() {
  local color="$1"
  shift
  printf "${color}%s${NC}" "$@"
}

print_in_red() {
  print_in_color "$RED" "$@"
}

print_in_green() {
  print_in_color "$GREEN" "$@"
}

print_in_yellow() {
  print_in_color "$YELLOW" "$@"
}

print_in_blue() {
  print_in_color "$BLUE" "$@"
}

print_in_purple() {
  print_in_color "$PURPLE" "$@"
}

print_in_cyan() {
  print_in_color "$CYAN" "$@"
}

print_in_white() {
  print_in_color "$WHITE" "$@"
}

print_success() {
  print_in_green "✓ $@\n"
}

print_error() {
  print_in_red "✗ $@\n"
}

print_warning() {
  print_in_yellow "⚠ $@\n"
}

print_info() {
  print_in_blue "ℹ $@\n"
}

print_question() {
  print_in_purple "? $@"
}

print_header() {
  echo ""
  print_in_cyan "====================================="
  print_in_cyan "$@"
  print_in_cyan "====================================="
  echo ""
}

print_step() {
  echo ""
  print_in_white "→ $@"
  echo ""
}

# =============================================================================
# CONFIRMATION FUNCTIONS
# =============================================================================

ask_for_confirmation() {
  print_question "$1 (y/n) "
  read -r -n 1 answer
  echo ""
}

answer_is_yes() {
  [[ "$answer" =~ ^[Yy]$ ]]
}

# =============================================================================
# SYSTEM UTILITIES
# =============================================================================

cmd_exists() {
  command -v "$1" &>/dev/null
}

is_macos() {
  [[ "$OSTYPE" == "darwin"* ]]
}

is_arm64() {
  [[ "$(uname -m)" == "arm64" ]]
}

get_os_version() {
  if is_macos; then
    sw_vers -productVersion
  else
    echo "unknown"
  fi
}

# =============================================================================
# FILE UTILITIES
# =============================================================================

create_symlink() {
  local source="$1"
  local target="$2"

  if [[ -z "$source" || -z "$target" ]]; then
    print_error "create_symlink: source and target required"
    return 1
  fi

  if [[ -L "$target" ]]; then
    rm "$target"
  elif [[ -f "$target" || -d "$target" ]]; then
    mv "$target" "$target.backup.$(date +%Y%m%d-%H%M%S)"
    print_warning "Backed up existing $target"
  fi

  ln -sf "$source" "$target"
  print_success "Created symlink: $target -> $source"
}

backup_file() {
  local file="$1"
  local backup_dir="${2:-$HOME/.dotfiles_backups}"

  if [[ -f "$file" && ! -L "$file" ]]; then
    mkdir -p "$backup_dir"
    cp "$file" "$backup_dir/$(basename "$file").backup.$(date +%Y%m%d-%H%M%S)"
    print_info "Backed up $file to $backup_dir"
  fi
}

# =============================================================================
# ENVIRONMENT DETECTION
# =============================================================================

detect_environment() {
  local current_dir="$PWD"
  local home_dir="$HOME"

  # Check if we're in a work directory
  if [[ "$current_dir" == *"/Work/"* ]] || [[ "$current_dir" == *"/work/"* ]]; then
    echo "work"
  elif [[ "$current_dir" == *"/Code/"* ]] || [[ "$current_dir" == *"/code/"* ]]; then
    echo "personal"
  else
    # Default to personal
    echo "personal"
  fi
}

# =============================================================================
# PACKAGE MANAGEMENT
# =============================================================================

install_if_missing() {
  local package="$1"
  local install_cmd="$2"

  if ! cmd_exists "$package"; then
    print_info "Installing $package..."
    eval "$install_cmd"
    if cmd_exists "$package"; then
      print_success "$package installed successfully"
    else
      print_error "Failed to install $package"
      return 1
    fi
  else
    print_success "$package is already installed"
  fi
}

# =============================================================================
# PROGRESS INDICATORS
# =============================================================================

show_spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while ps -p "$pid" >/dev/null 2>&1; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

run_with_spinner() {
  local message="$1"
  shift
  local cmd="$@"

  print_info "$message"
  $cmd &
  local pid=$!
  show_spinner $pid
  wait $pid
  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    print_success "Complete"
  else
    print_error "Failed"
  fi

  return $exit_code
}

# =============================================================================
# NETWORKING
# =============================================================================

download_file() {
  local url="$1"
  local destination="$2"

  if cmd_exists "curl"; then
    curl -fsSL "$url" -o "$destination"
  elif cmd_exists "wget"; then
    wget -q "$url" -O "$destination"
  else
    print_error "Neither curl nor wget found"
    return 1
  fi
}

check_internet() {
  if ping -c 1 google.com &>/dev/null; then
    return 0
  else
    print_error "No internet connection"
    return 1
  fi
}

# =============================================================================
# VALIDATION
# =============================================================================

validate_email() {
  local email="$1"
  local regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

  if [[ "$email" =~ $regex ]]; then
    return 0
  else
    return 1
  fi
}

validate_url() {
  local url="$1"
  local regex="^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}.*$"

  if [[ "$url" =~ $regex ]]; then
    return 0
  else
    return 1
  fi
}

# =============================================================================
# CLEANUP
# =============================================================================

cleanup_temp_files() {
  local temp_dir="${1:-/tmp/dotfiles_install}"

  if [[ -d "$temp_dir" ]]; then
    rm -rf "$temp_dir"
    print_info "Cleaned up temporary files"
  fi
}

# =============================================================================
# LOGGING
# =============================================================================

log() {
  local level="$1"
  shift
  local message="$@"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local log_file="${DOTFILES_LOG_FILE:-$HOME/.dotfiles_install.log}"

  echo "[$timestamp] [$level] $message" >>"$log_file"

  case "$level" in
  "ERROR")
    print_error "$message"
    ;;
  "WARNING")
    print_warning "$message"
    ;;
  "INFO")
    print_info "$message"
    ;;
  "SUCCESS")
    print_success "$message"
    ;;
  *)
    echo "$message"
    ;;
  esac
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Create log file if it doesn't exist
mkdir -p "$(dirname "${DOTFILES_LOG_FILE:-$HOME/.dotfiles_install.log}")"
touch "${DOTFILES_LOG_FILE:-$HOME/.dotfiles_install.log}"

# Export functions for use in other scripts
export -f print_in_color print_in_red print_in_green print_in_yellow print_in_blue
export -f print_in_purple print_in_cyan print_in_white
export -f print_success print_error print_warning print_info print_question
export -f print_header print_step
export -f ask_for_confirmation answer_is_yes
export -f cmd_exists is_macos is_arm64 get_os_version
export -f create_symlink backup_file detect_environment
export -f install_if_missing show_spinner run_with_spinner
export -f download_file check_internet validate_email validate_url
export -f cleanup_temp_files log
