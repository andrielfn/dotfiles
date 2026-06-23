#!/usr/bin/env bash
# =============================================================================
# 1PASSWORD REFERENCES (setup-time only)
# =============================================================================
# These are POINTERS, not secrets — safe to commit. They tell the setup
# installers which 1Password items to materialize. 1Password is used ONLY at
# setup time; nothing here is read at shell runtime.
#
# IMPORTANT: always reference items by ID. Item titles containing special
# characters (e.g. parentheses) break op:// secret references.
#
# Override any of these via the environment before running an installer.

# SSH key item (Personal vault).
#   file attachments: id_ed25519, id_ed25519.pub   field: password (passphrase)
: "${OP_SSH_ITEM:=op://Personal/xtn5viccnbhqpoh6inldlsl2o4}"

# GitHub Personal Access Token (Environment vault).
# Required scopes: admin:public_key, admin:ssh_signing_key.
: "${OP_GH_PAT:=op://Environment/GITHUB_PAT/credential}"

# SOPS age key (LastVolt vault, Secure Note) — the note body is the keys.txt
# content. Materialized to ~/.config/sops/age/keys.txt (SOPS_AGE_KEY_FILE).
: "${OP_SOPS_AGE:=op://LastVolt/p67hnqvvoi3gflgxwfljfgepii/notesPlain}"

export OP_SSH_ITEM OP_GH_PAT OP_SOPS_AGE

# Ensure `op` exists and is signed in. Requires utils.sh sourced first (print_*).
require_op() {
  if ! command -v op >/dev/null 2>&1; then
    print_error "1Password CLI (op) not found — install: brew install --cask 1password-cli"
    return 1
  fi
  if ! op whoami >/dev/null 2>&1 && ! op account get >/dev/null 2>&1; then
    print_info "Signing in to 1Password..."
    eval "$(op signin)" || { print_error "1Password sign-in failed"; return 1; }
  fi
  return 0
}
