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
  printf "${color}%b${NC}" "$@"
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
  # Check for work-specific directories in home
  if [[ -d "$HOME/Work" ]] || [[ -d "$HOME/work" ]]; then
    echo "work"
  else
    echo "personal"
  fi
}

# =============================================================================
# MAPPING-BASED CONFIGURATION MANAGEMENT
# =============================================================================

setup_configurations() {
  local dotfiles_dir="$1"
  local mapping_file="$dotfiles_dir/configs/mapping"

  if [[ ! -f "$mapping_file" ]]; then
    print_warning "No mapping file found at $mapping_file"
    return 0
  fi

  print_header "Setting up configurations"

  # Create necessary directories
  mkdir -p "$HOME/.config"

  # Read the mapping file and create symlinks
  while IFS=':' read -r source_path dest_path || [[ -n "$source_path" ]]; do
    # Skip comments and empty lines
    [[ "$source_path" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$source_path" ]] && continue

    # Trim whitespace
    source_path=$(echo "$source_path" | xargs)
    dest_path=$(echo "$dest_path" | xargs)

    # Skip if dest_path is empty
    [[ -z "$dest_path" ]] && continue

    # Expand tilde in destination path
    dest_path=$(eval echo "$dest_path")

    # Check if this is a folder mapping (ends with /)
    if [[ "$source_path" == */ ]]; then
      setup_folder_mapping "$dotfiles_dir" "$source_path" "$dest_path"
    else
      # Individual file mapping
      setup_file_mapping "$dotfiles_dir" "$source_path" "$dest_path"
    fi

  done <"$mapping_file"

  print_success "All configurations set up"
}

setup_file_mapping() {
  local dotfiles_dir="$1"
  local source_path="$2"
  local dest_path="$3"

  # Get full source path
  local full_source="$dotfiles_dir/configs/$source_path"

  # Check if source exists
  if [[ ! -e "$full_source" ]]; then
    print_warning "Source file not found: $full_source"
    return 1
  fi

  # Create destination directory if needed
  local dest_dir=$(dirname "$dest_path")
  if [[ ! -d "$dest_dir" ]]; then
    mkdir -p "$dest_dir"
  fi

  # Setup the configuration
  setup_config_link "$full_source" "$dest_path" "$source_path"
}

setup_folder_mapping() {
  local dotfiles_dir="$1"
  local source_path="$2"
  local dest_path="$3"

  # Remove trailing slash from source_path for directory operations
  local source_dir="$dotfiles_dir/configs/${source_path%/}"

  # Check if source directory exists
  if [[ ! -d "$source_dir" ]]; then
    print_warning "Source directory not found: $source_dir"
    return 1
  fi

  # Create destination directory if needed
  if [[ ! -d "$dest_path" ]]; then
    mkdir -p "$dest_path"
  fi

  # Map all files in the source directory to the destination
  for source_file in "$source_dir"/*; do
    if [[ -e "$source_file" ]]; then
      local file_name=$(basename "$source_file")
      local dest_file="${dest_path%/}/$file_name"
      local display_name="${source_path%/}/$file_name"

      # Setup individual file link
      setup_config_link "$source_file" "$dest_file" "$display_name"
    fi
  done
}

setup_config_link() {
  local source_path="$1"
  local dest_path="$2"
  local display_name="$3"

  print_step "Setting up $display_name configuration..."

  # Backup existing config if it exists and is not a symlink
  if [[ -e "$dest_path" && ! -L "$dest_path" ]]; then
    # Create backup directory based on config type
    local backup_subdir=$(dirname "$display_name")
    if [[ "$backup_subdir" == "." ]]; then
      backup_subdir="home"
    fi
    backup_file "$dest_path" "$HOME/.dotfiles_backups/$backup_subdir"
  fi

  # Create symlink
  create_symlink "$source_path" "$dest_path"
  print_success "$display_name configuration linked"
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
export -f create_symlink backup_file detect_environment setup_configurations setup_file_mapping setup_folder_mapping setup_config_link
export -f install_if_missing show_spinner run_with_spinner
export -f download_file check_internet validate_email validate_url
export -f cleanup_temp_files log
