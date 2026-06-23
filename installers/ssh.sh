#!/usr/bin/env bash
# =============================================================================
# SSH KEY INSTALLER (1Password → disk, setup-time only)
# =============================================================================
# Materializes the SSH key from 1Password to ~/.ssh and loads it into the macOS
# keychain. After this, runtime uses the on-disk key + ssh-agent — no 1Password.

set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/scripts/utils.sh"
source "$DIR/scripts/op-refs.sh"

SSH_KEY="$HOME/.ssh/id_ed25519"

write_key() {
  print_step "Writing SSH key from 1Password"
  # Write to adjacent temp files (strict umask) and mv into place only on success,
  # so a failed `op read` can't clobber an existing key. Private key never has a
  # world-readable window.
  local tmp_priv="$SSH_KEY.tmp.$$" tmp_pub="$SSH_KEY.pub.tmp.$$"
  trap 'rm -f "$tmp_priv" "$tmp_pub"' RETURN   # clean up temps on any exit path
  if ( umask 077; op read "$OP_SSH_ITEM/id_ed25519" >"$tmp_priv" ) && [[ -s "$tmp_priv" ]] \
    && op read "$OP_SSH_ITEM/id_ed25519.pub" >"$tmp_pub" && [[ -s "$tmp_pub" ]]; then
    chmod 600 "$tmp_priv"
    chmod 644 "$tmp_pub"
    mv -f "$tmp_priv" "$SSH_KEY"
    mv -f "$tmp_pub" "$SSH_KEY.pub"
    print_success "Wrote $SSH_KEY (+ .pub)"
  else
    print_error "Failed to read SSH key from 1Password — left existing key untouched"
    return 1
  fi
}

add_to_keychain() {
  print_step "Loading key into ssh-agent + macOS keychain"
  local pass askpass
  pass="$(op read "$OP_SSH_ITEM/password" 2>/dev/null || true)"

  if [[ -n "$pass" ]]; then
    # Pass the passphrase to ssh-add via an askpass helper. The passphrase is
    # passed through the environment, never written to the temp file.
    askpass="$(mktemp)"
    chmod 700 "$askpass"
    trap 'rm -f "$askpass"' RETURN
    printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$OP_SSH_PASS"\n' >"$askpass"
    if OP_SSH_PASS="$pass" SSH_ASKPASS="$askpass" SSH_ASKPASS_REQUIRE=force DISPLAY=:0 \
      ssh-add --apple-use-keychain "$SSH_KEY" </dev/null 2>/dev/null; then
      print_success "Key added to keychain (passphrase from 1Password)"
    else
      print_warning "Auto-add failed — run manually: ssh-add --apple-use-keychain $SSH_KEY"
    fi
  else
    ssh-add --apple-use-keychain "$SSH_KEY" \
      && print_success "Key added to keychain" \
      || print_warning "Could not add key to agent — run: ssh-add --apple-use-keychain $SSH_KEY"
  fi
}

main() {
  require_op || exit 1
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [[ -f "$SSH_KEY" ]]; then
    ask_for_confirmation "SSH key exists at $SSH_KEY — overwrite from 1Password?"
    if answer_is_yes; then write_key; else print_info "Keeping existing key"; fi
  else
    write_key
  fi

  add_to_keychain
  print_success "SSH key ready"
}

main "$@"
