#!/usr/bin/env bash

# =============================================================================
# CONFIGURATION MANAGEMENT FUNCTIONS
# =============================================================================
# This file handles the mapping-based configuration system for dotfiles

source "$(dirname "$0")/utils.sh"

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
  mkdir -p "$HOME/.gnupg"

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

# Export functions for use in other scripts
export -f setup_configurations setup_file_mapping setup_folder_mapping setup_config_link
