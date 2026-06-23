#!/usr/bin/env bash
# =============================================================================
# ENVIRONMENT SECRETS — TEMPLATE (tracked)
# =============================================================================
# Real values are injected by `dotfiles secrets` (op inject) into
# shell/secrets (gitignored). Edit THIS file and the 1Password items it points
# to — never edit the generated shell/secrets directly.
#
# Source: "Environment" vault, one API Credential item per secret (field:
# `credential`). Item titles match the variable name, so refs are 1:1.

# --- AI ---
export ANTHROPIC_API_KEY="op://Environment/ANTHROPIC_API_KEY/credential"

# --- GitHub (PAT reused for Homebrew API rate limits) ---
export GITHUB_PAT="op://Environment/GITHUB_PAT/credential"
export HOMEBREW_GITHUB_API_TOKEN="$GITHUB_PAT"

# --- AWS ---
export AWS_ACCESS_KEY_ID="op://Environment/AWS_ACCESS_KEY_ID/credential"
export AWS_SECRET_ACCESS_KEY="op://Environment/AWS_SECRET_ACCESS_KEY/credential"

# --- Bunny CDN ---
export BUNNY_CDN_API_KEY="op://Environment/BUNNY_CDN_API_KEY/credential"

# --- Ansible vault ---
export VAULT_PASSWORD="op://Environment/VAULT_PASSWORD/credential"

# --- Code backup (restic + Backblaze B2) ---
export CODE_BACKUP_RESTIC_PASSWORD="op://Environment/CODE_BACKUP_RESTIC_PASSWORD/credential"
export CODE_BACKUP_B2_ACCOUNT_ID="op://Environment/CODE_BACKUP_B2_ACCOUNT_ID/credential"
export CODE_BACKUP_B2_ACCOUNT_KEY="op://Environment/CODE_BACKUP_B2_ACCOUNT_KEY/credential"
