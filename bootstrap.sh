#!/usr/bin/env bash
# =============================================================================
# DOTFILES BOOTSTRAP — one command to set up a fresh Mac
# =============================================================================
# Usage:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/andrielfn/dotfiles/main/bootstrap.sh)"
#
# Installs Xcode Command Line Tools + Homebrew, clones the dotfiles, and runs
# the full setup (packages, mise tools, shell, macOS prefs, and the 1Password
# bootstrap for SSH key / secrets / commit signing). Idempotent — safe to re-run.

set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/andrielfn/dotfiles}"
# Pinned to ~/.dotfiles — bin/dotfiles and shell/init.sh assume this path.
DEST="$HOME/.dotfiles"

log() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

# 1. Xcode Command Line Tools (provides git + compilers)
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (accept the GUI prompt)..."
  xcode-select --install || true
  log "Waiting for Command Line Tools to finish installing..."
  tries=0
  until xcode-select -p >/dev/null 2>&1; do
    tries=$((tries + 1))
    if (( tries > 180 )); then  # ~15 min
      echo "Command Line Tools not detected after 15 min." >&2
      echo "Accept the install dialog (or run 'xcode-select --install'), then re-run this command." >&2
      exit 1
    fi
    sleep 5
  done
  log "Command Line Tools installed"
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Put brew on PATH for this session
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Clone (or update) the dotfiles
if [[ ! -d "$DEST/.git" ]]; then
  log "Cloning dotfiles into $DEST..."
  git clone "$REPO_URL" "$DEST"
else
  log "Dotfiles already present at $DEST — pulling latest..."
  git -C "$DEST" pull --ff-only || true
fi

# 4. Run the full setup. Read prompts from the terminal even when this script
#    was piped (curl | bash), so 1Password sign-in / confirmations still work.
log "Running full setup..."
cd "$DEST"
if [[ -t 0 ]]; then
  ./setup.sh --full
elif [[ -e /dev/tty ]]; then
  ./setup.sh --full </dev/tty
else
  ./setup.sh --full
fi

log "Done — restart your terminal or run: exec \$SHELL -l"
