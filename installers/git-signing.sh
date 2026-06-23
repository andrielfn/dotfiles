#!/usr/bin/env bash
# =============================================================================
# GIT SIGNING INSTALLER (GitHub key registration, setup-time only)
# =============================================================================
# Authenticates gh (PAT from 1Password) and registers the SSH public key on
# GitHub as both an authentication key and a signing key, so SSH-signed commits
# show "Verified". Idempotent — safe to re-run.

set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/scripts/utils.sh"
source "$DIR/scripts/op-refs.sh"

# gh is managed by mise; ensure it's on PATH during setup (the setup shell does
# not source shell/exports.sh). Prefer `mise activate` so a custom MISE_DATA_DIR
# is honored; fall back to the default shims path.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)" 2>/dev/null || export PATH="$HOME/.local/share/mise/shims:$PATH"
else
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

SSH_KEY="$HOME/.ssh/id_ed25519"

main() {
  if ! command -v gh >/dev/null 2>&1; then
    print_error "gh not found — install via mise (mise install) or brew"
    exit 1
  fi
  if [[ ! -f "$SSH_KEY.pub" ]]; then
    print_error "No public key at $SSH_KEY.pub — run 'dotfiles ssh' first"
    exit 1
  fi

  # Authenticate gh using the PAT from 1Password (only if not already authed).
  if gh auth status >/dev/null 2>&1; then
    print_success "gh already authenticated"
  else
    require_op || exit 1
    print_step "Authenticating gh with PAT from 1Password"
    if op read "$OP_GH_PAT" | gh auth login --with-token; then
      print_success "gh authenticated"
    else
      print_warning "Could not authenticate gh from $OP_GH_PAT."
      print_info "Check the PAT item, or run 'gh auth login' manually, then re-run 'dotfiles signing'."
      exit 0
    fi
  fi

  local title
  title="$(scutil --get ComputerName 2>/dev/null || hostname -s)"

  print_step "Registering SSH key on GitHub"
  if gh ssh-key add "$SSH_KEY.pub" --title "$title" 2>/dev/null; then
    print_success "Authentication key registered"
  else
    print_info "Authentication key already present (or skipped)"
  fi
  if gh ssh-key add "$SSH_KEY.pub" --type signing --title "$title (signing)" 2>/dev/null; then
    print_success "Signing key registered"
  else
    print_info "Signing key already present (or skipped)"
  fi
}

main "$@"
