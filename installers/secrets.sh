#!/usr/bin/env bash
# =============================================================================
# SECRETS INSTALLER (1Password → shell/secrets, setup-time only)
# =============================================================================
# Injects real secret values from 1Password into shell/secrets using `op inject`
# against shell/secrets.tpl. The generated file is gitignored and is sourced at
# shell startup like a plain env file — no 1Password at runtime.

set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/scripts/utils.sh"
source "$DIR/scripts/op-refs.sh"

TPL="$DIR/shell/secrets.tpl"
OUT="$DIR/shell/secrets"
SOPS_AGE_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

# Materialize the SOPS age key from 1Password to disk (setup-time only).
materialize_sops_age_key() {
  [[ -n "${OP_SOPS_AGE:-}" ]] || return 0
  print_step "Materializing SOPS age key from 1Password"
  mkdir -p "$(dirname "$SOPS_AGE_FILE")"
  # Write to an adjacent temp file (strict umask, never world-readable) and only
  # mv into place on success — so a failed `op read` can't clobber an existing key.
  local tmp="$SOPS_AGE_FILE.tmp.$$"
  trap 'rm -f "$tmp"' RETURN   # clean up temp on any exit path
  if ( umask 077; op read "$OP_SOPS_AGE" >"$tmp" ) && [[ -s "$tmp" ]]; then
    chmod 600 "$tmp"
    mv -f "$tmp" "$SOPS_AGE_FILE"
    print_success "Wrote $SOPS_AGE_FILE (chmod 600)"
  else
    print_warning "Could not read SOPS age key from $OP_SOPS_AGE — left existing file untouched"
  fi
}

main() {
  if [[ ! -f "$TPL" ]]; then
    print_error "Template not found: $TPL"
    exit 1
  fi

  if grep -q 'CHANGEME' "$TPL"; then
    print_warning "Template still has CHANGEME placeholders."
    print_info "Edit $TPL with real 1Password item IDs, then re-run."
    exit 1
  fi

  require_op || exit 1

  print_step "Injecting secrets from 1Password"
  op inject -i "$TPL" -o "$OUT" -f
  chmod 600 "$OUT"
  print_success "Wrote $OUT (chmod 600)"

  materialize_sops_age_key

  print_success "Secrets ready — reload your shell to load."
}

main "$@"
