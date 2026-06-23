# Dotfiles Rework — Plan

## Goal
Make a fresh-Mac setup fully reproducible and automate the manual steps (SSH key,
signed commits, secrets) via 1Password **at setup time only** (no runtime 1P
dependency). Consolidate package sources of truth. Migrate select CLIs to mise.

## Decisions (locked)
- 1Password is **setup-time only**. Keys/secrets are materialized to disk; runtime
  uses native on-disk key + ssh-agent/keychain. No `op` calls in `shell/`.
- Commit signing: **SSH** (`gpg.format = ssh`), **same key** for personal + work.
- `gh` auth at setup via **GitHub PAT read from 1P** (hands-off).
- SSH key item (1P, Personal vault), referenced by **item ID**:
  - private  `op://Personal/xtn5viccnbhqpoh6inldlsl2o4/id_ed25519`
  - public   `op://Personal/xtn5viccnbhqpoh6inldlsl2o4/id_ed25519.pub`
  - passphrase `op://Personal/xtn5viccnbhqpoh6inldlsl2o4/password`
- Secrets in 1P: **one item per credential** (API Credential category, Personal
  vault), referenced by ID. User creates these; template carries placeholders.
- Brew: leave this machine as-is (no uninstall). Brewfiles are desired-state only.
- Restic backup wiring: **deferred** (out of scope this round).

## Slice 1 — Package consolidation + mise migration  ✅ DONE
- [x] Move to `config/mise/config.toml` (pinned `latest`): gh, jq, yq, difftastic,
      gum, flyctl, hcloud. Add `just` (used heavily, currently unpinned).
- [x] Remove those 7 from `env/shared/Brewfile`; strip `[mise]` markers + header note.
- [x] Remove now-unused `tap "hashicorp/tap"` (packer was pruned).
- [x] Keep bat/eza/fd/ripgrep/fzf in brew (interactive hot path).
- [x] Verify: `mise install` the new tools (all 8 resolve); Brewfiles parse.
- [x] Refactor `bin/dotfiles`: delete `BREW_PACKAGES` array; `setup`/`doctor` use
      `brew bundle` + `mise` (single source of truth). `doctor` runs clean.
- Note: `brew bundle check` flags manually-installed apps (ghostty/zed/claude/etc.)
  as "missing" — expected; `dotfiles setup` would brew-install them on a fresh Mac.

## Slice 2 — Git SSH signing  ✅ DONE (verified)
- [x] `env/shared/.gitconfig`: `gpg.format = ssh`; `[gpg "ssh"] allowedSignersFile`;
      dropped `gpg.program = gpg`; kept `commit.gpgsign = true`.
- [x] `.gitconfig-personal` + `.gitconfig-work`: `signingkey = ~/.ssh/id_ed25519.pub`.
- [x] Added `config/git/allowed_signers` (both emails → pubkey); mapped in mapping.cfg.
- [x] Verified: signed commit shows `Good "git" signature`, no passphrase prompt.
- ⚠ User blanked the work `email` in .gitconfig-work — needs filling if work machine used.

## Slice 3 — 1Password setup automation  ✅ DONE (built; op steps not run)
- [x] `scripts/op-refs.sh`: central op:// pointers + `require_op` sign-in helper.
- [x] `env/shared/env-secrets.tpl` (tracked): op:// placeholder refs.
- [x] `installers/secrets.sh`: validates template, `op inject` → env-secrets (600).
- [x] `installers/ssh.sh`: materialize id_ed25519(.pub) from 1P + keychain (askpass,
      passphrase via env not disk).
- [x] `installers/git-signing.sh`: PAT → `gh auth login --with-token`; `gh ssh-key
      add` auth + `--type signing` (idempotent).
- [x] `bin/dotfiles`: `ssh`/`secrets`/`signing` subcommands; wired into `setup.sh`.
- [x] Verified: syntax + shellcheck clean; CHANGEME guard works without op auth.

## Slice 4 — Cleanup  ✅ DONE
- [x] Deleted stray `config/ghostty/config.bak.*`; gitignored `*.bak` / `*.bak.*`.
- [x] Moved machine-specific `safe.directory` to untracked `~/.gitconfig.local`
      (via `[include]`); git still resolves it.

## Secrets wired to "Environment" vault  ✅ DONE
- [x] 9 API Credential items created in Environment vault (by user).
- [x] `env-secrets.tpl` references all 9 (field `credential`) + HOMEBREW alias.
- [x] `OP_GH_PAT` → `op://Environment/GITHUB_PAT/credential`.
- [x] Ran `dotfiles secrets` → env-secrets generated (600, gitignored), 10/10 resolve.
- [x] Removed redundant `env/shared/env-secrets.example` (superseded by .tpl).
- Note: dropped OPENAI_API_KEY (item not created). SSH key stays in Personal vault.

## Slice 5 — Flatten env/ (no personal/shared/work folders)  ✅ DONE
- [x] Merged 3 Brewfiles → `env/Brewfile`; 3 env files → `env/env.sh`.
- [x] `env/secrets.tpl` + generated `env/secrets`; kept `env/.gitconfig{,-personal,-work}`.
- [x] Updated all refs: init.sh, homebrew.sh, bin/dotfiles, secrets.sh, exports.sh,
      .gitignore, setup.sh (always links both identity configs), restic plist, bin/backup,
      README.md, CLAUDE.md. Relinked ~/.gitconfig*.
- [x] Verified: env.sh sources, secrets regen (10/10), Brewfile parses (64), signing
      works, all scripts syntax-clean, no stale refs.
- Bonus: `bin/backup` already consumes CODE_BACKUP_* — secrets now feed it directly.

## Code review fixes  ✅ DONE (all 10 + bootstrap)
- [x] #1 mise install before config linked → `installers/mise.sh` self-links config.toml;
      `bin/dotfiles` links before mise install.
- [x] #2 git-signing needs gh (mise) → `git-signing.sh` adds mise shims to PATH.
- [x] #3 restic + git-lfs added to Brewfile (needed by bin/backup + lfs filter).
- [x] #4 ssh.sh writes private key under `umask 077` (no world-readable window).
- [x] #5 setup.sh no longer auto-creates ~/Work; gitconfig-work documents empty email.
- [x] #6 ssh.sh non-passphrase branch no longer aborts under set -e (`|| print_warning`).
- [x] #7 removed `eval echo` from doctor symlink loop.
- [x] #8 git-signing CHANGEME dead-guard replaced with graceful op-read failure handling.
- [x] #9 symlink scan dedup'd into `mapping_dests()` (status/doctor/clean).
- [x] #10 removed dead 1Password runtime block + duplicate detect_environment in init.sh;
      repointed --work-dir sed to utils.sh.
- [x] BOOTSTRAP: `bootstrap.sh` (curl one-liner) + `setup.sh --full` non-interactive flag.
- [x] Verified: bash -n all, shellcheck clean (1 pre-existing SC2155), doctor all green.

## Still outstanding (optional / fresh-machine)
- [ ] Run `dotfiles signing` to register current key on GitHub as a signing key
      (OP_GH_PAT now wired) — makes commits show "Verified". Outward action; confirm.
- [ ] On a fresh Mac: `dotfiles ssh` materializes the key from 1P.
- [ ] calmwave removed. Work identity left blank/generic for a future job.

## Acceptance criteria
- `brew bundle check` passes against shared+personal Brewfiles on this machine.
- `mise install` resolves all global tools; moved CLIs work via mise shims.
- New commits are SSH-signed and verify locally (allowed_signers) + on GitHub.
- A documented one-command path materializes SSH key + secrets from 1P on a new Mac.

## Working notes
- 1P item titles with `()` break `op://` refs — always use item **IDs**.
- SSH key is passphrase-protected; keychain stores passphrase after setup.
- Public key: `ssh-ed25519 AAAA…MpX5 andrielfn@gmail.com`.
