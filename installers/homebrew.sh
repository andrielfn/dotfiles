#!/usr/bin/env bash

# Homebrew installer with environment-specific package management
# This script installs Homebrew and manages packages based on the current environment

source "$(dirname "$0")/../scripts/utils.sh"

# Environment detection function is now in utils.sh

# Put an already-installed brew on PATH. setup.sh runs in a non-login shell that
# hasn't sourced ~/.zprofile, so `command -v brew` would miss an existing install
# and wrongly re-run the installer.
load_brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew() {
  print_in_yellow "=> Installing Homebrew...\n"

  load_brew_shellenv
  if command -v brew &>/dev/null; then
    # Don't run `brew update` here — it's slow and does a git fetch that can fail
    # before SSH is set up. `brew bundle` picks up new packages regardless.
    print_success "Homebrew already installed"
    return 0
  fi

  # Install Homebrew non-interactively (sudo already primed by setup.sh/bootstrap).
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  load_brew_shellenv
  print_success "Homebrew installed successfully"
}

install_packages() {
  local dotfiles_dir="$1"

  print_in_yellow "=> Installing packages from Brewfile\n"

  if [[ ! -f "$dotfiles_dir/Brewfile" ]]; then
    print_warning "Brewfile not found"
    return 0
  fi

  print_info "brew bundle installs only what's missing (already-installed packages are skipped)."
  print_info "Large app downloads can be slow or time out — failures auto-retry and won't stop the rest."

  # NO_AUTO_UPDATE: skip the slow/failure-prone git update.
  # NO_ENV_HINTS:   quiet the post-install hint spam.
  # CURL_RETRIES:   retry each flaky vendor-CDN download before giving up.
  local -x HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_CURL_RETRIES=3

  # Retry the whole bundle a few times. Each pass skips what's already installed,
  # so only the previously-failed packages are re-attempted. Never fatal — a slow
  # CDN shouldn't block the rest of setup.
  local attempt=1 max=3
  while true; do
    if brew bundle --file="$dotfiles_dir/Brewfile"; then
      print_success "All packages installed"
      break
    fi
    if (( attempt >= max )); then
      print_warning "Some packages still failed after $max attempts (usually slow app CDNs or a VPN)."
      print_warning "Finish them later with: brew bundle --file=\"$dotfiles_dir/Brewfile\""
      break
    fi
    attempt=$((attempt + 1))
    print_warning "Retrying packages that failed (attempt $attempt/$max)…"
    sleep 3
  done

  brew cleanup
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
