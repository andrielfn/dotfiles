# Dotfiles

macOS dotfiles: a single Brewfile + mise config for tools, a mapping-based symlink
system for configs, and 1Password-backed setup of the SSH key, secrets, and commit
signing. A fresh Mac is provisioned with one command.

## New MacBook Setup

**One command** — installs Command Line Tools + Homebrew, clones the repo, and runs the full setup:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/andrielfn/dotfiles/main/bootstrap.sh)"
```

You'll be prompted to sign in to 1Password (for the SSH key, secrets, and commit-signing setup) and for a few confirmations. Then restart your terminal.

### Manual steps (equivalent)

```bash
xcode-select --install
git clone https://github.com/andrielfn/dotfiles ~/.dotfiles
cd ~/.dotfiles
./setup.sh --full          # or ./setup.sh for the interactive menu
```

For a work machine: `./setup.sh --machine-type=work [--work-dir=Company]`.

### What full setup does
1. Homebrew + packages (`Brewfile`)
2. Links all configs (`config/mapping.cfg`) — including the mise config
3. Installs mise tools (runtimes + dev CLIs)
4. Oh My Zsh + plugins, sets zsh as default shell
5. (optional) macOS system preferences
6. 1Password bootstrap: materializes the SSH key, injects secrets, registers the GitHub signing key

## Machine Setup Options

The setup script automatically configures your machine based on the type specified:

**Machine Types:**
- **Personal** (default): creates `~/Code/` for personal projects
- **Work**: creates the work directory (default `~/Work/`); commits there use the work git identity

The machine type only affects which project directory is created. Git identity is
selected per-directory via `includeIf` (see Git Configuration), and the same tools,
secrets, and configs are installed everywhere.

**Command Line Options:**
- `--machine-type=TYPE`: Set machine type (`personal` or `work`)
- `--work-dir=DIR`: Set custom work directory name (default: `Work`)
- `--help`: Show usage information

## Installation Options

The setup script provides four installation modes:

- **Full Setup**: Complete environment with packages, shell configuration, and macOS settings
- **Package Management Only**: Homebrew and development tools installation
- **Shell Configuration Only**: ZSH configuration with modern tools and aliases
- **macOS Configuration Only**: System preferences and developer settings

## Project Structure

```
dotfiles/
├── config/                 # Configuration files managed by mapping system
│   ├── mapping.cfg        # File mapping configuration
│   ├── zshrc              # Main ZSH configuration
│   ├── starship.toml      # Starship prompt configuration
│   ├── git/               # Git configuration files
│   ├── zed/               # Zed editor configuration
│   ├── mise/              # Mise tool configuration
│   └── ...
├── shell/                 # Shell library (sourced by zshrc)
│   ├── aliases.sh         # Command aliases
│   ├── functions.sh       # Shell functions
│   ├── exports.sh         # PATH manipulation and shell-specific logic
│   ├── env.sh             # Environment variables
│   ├── secrets.tpl        # 1Password secret template (op:// refs)
│   ├── secrets            # Generated secrets (gitignored)
│   └── init.sh            # Tool initialization and environment loading
├── bin/                   # Executable commands
│   └── dotfiles           # Main management utility
├── installers/            # Installation scripts (homebrew, mise, ssh, secrets, …)
├── scripts/               # Setup utilities
├── Brewfile               # Homebrew package manifest
└── setup.sh               # Main installation script
```

## Dotfiles Management

The `dotfiles` command provides centralized management:

```bash
dotfiles setup     # Install/repair all dependencies (brew, mise, omz, plugins, links)
dotfiles ssh       # Materialize SSH key from 1Password into ~/.ssh + keychain
dotfiles secrets   # Inject secrets from 1Password into shell/secrets (op inject)
dotfiles signing   # Register SSH key on GitHub (auth + signing) via gh
dotfiles edit      # Open dotfiles in $EDITOR
dotfiles update    # Pull latest changes and relink configurations
dotfiles link      # Link all configurations from mapping file
dotfiles status    # Show current dotfiles status
dotfiles doctor    # Full health check (brew, mise, links, signing, ssh, secrets, op)
dotfiles reload    # Reload shell configuration
dotfiles clean     # Remove broken symlinks
dotfiles sync      # Commit and push changes
dotfiles help      # Show available commands
```

## 1Password integration (setup-time only)

The SSH key, secrets, and GitHub commit-signing key are all provisioned from
1Password **during setup** and then live natively on disk — nothing calls 1Password
at shell runtime (no per-commit / per-shell `op` latency).

- `dotfiles ssh` — reads the SSH key from 1Password into `~/.ssh/id_ed25519` (+ keychain).
- `dotfiles secrets` — `op inject`s `shell/secrets.tpl` → `shell/secrets` (gitignored),
  and materializes the SOPS age key from 1Password to `~/.config/sops/age/keys.txt`.
- `dotfiles signing` — authenticates `gh` with a PAT from 1Password and registers the
  key on GitHub (auth + signing).

1Password item references live in `scripts/op-refs.sh` (SSH key, GitHub PAT, SOPS age
key) and `shell/secrets.tpl` (env secrets, in the "Environment" vault).

## Configuration

### Environment Variables

The system loads environment variables in this order:
1. Public variables (`shell/env.sh`)
2. Secrets (`shell/secrets`)

**Public Environment Variables** - Edit the tracked file directly: `shell/env.sh`.

**Secrets** - Secrets live in 1Password and are materialized to `shell/secrets`
(gitignored) at setup time via `op inject`. Edit the template `shell/secrets.tpl`
(it references `op://` items) and regenerate with:

```bash
dotfiles secrets
```

1Password is used only at setup; nothing reads it at shell runtime.

**Personal Customizations** - For local-only settings, add to `~/.zshrc.local`:

```bash
# Machine-specific aliases or overrides
alias myproject="cd ~/Code/my-project"
export LOCAL_SETTING="value"
```

### Shell Configuration

**Personal Customizations** - Add to `~/.zshrc.local`:

```bash
# Custom aliases
alias myproject="cd ~/Code/my-project"
alias deploy="./deploy.sh"

# Custom functions
quick_commit() {
    git add . && git commit -m "$1" && git push
}
```

**Core Configuration** - Edit files in the appropriate directories:

- `config/zshrc` - Main ZSH configuration
- `shell/aliases.sh` - Command aliases
- `shell/functions.sh` - Shell functions
- `shell/exports.sh` - PATH manipulation and shell-specific logic
- `shell/env.sh` - Environment variables

After editing shell files, run `dotfiles reload` to restart your shell.
After editing config files, run `dotfiles link` to update symlinks.

### Git Configuration

Commits are SSH-signed (`gpg.format = ssh`) using `~/.ssh/id_ed25519.pub`, with
identity selected by directory via `includeIf`.

**Personal Settings** - Edit `config/git/gitconfig-personal` (used in `~/Code/`):

```bash
[user]
    name = "Your Name"
    email = "personal@email.com"
    signingkey = ~/.ssh/id_ed25519.pub
```

**Work Settings** - Edit `config/git/gitconfig-work` (used in `~/Work/`).

**Global Settings** - Edit `config/git/gitconfig`

### Tool Management

Two sources of truth, by role:

- **`Brewfile`** (Homebrew) — system libs, services, shell-init-critical tools
  (starship/atuin/zoxide/direnv), hot-path CLIs (bat/eza/fd/ripgrep/fzf), GUI casks.
- **`config/mise/config.toml`** (mise) — language runtimes + version-flexible dev/infra
  CLIs (gh, jq, yq, difftastic, gum, flyctl, hcloud, just).

```bash
# Edit Brewfile / config/mise/config.toml, then:
brew bundle --file=Brewfile     # apply package changes
mise install                    # apply tool changes
# or just: dotfiles setup

# Per-project tool versions go in a project-level mise.toml, e.g.:
mise use elixir@1.19 erlang@28
```

`dotfiles doctor` also reports **drift** — packages installed but not in the Brewfile.

### Adding New Configuration Files

To add new configuration files to the mapping system:

1. Place the file in the `config/` directory
2. Add an entry to `config/mapping.cfg` following the format:
   ```
   source_file:destination_path
   ```
3. Run `dotfiles link` to create the symlink

### Applying Changes

After making configuration changes:

```bash
dotfiles reload    # Restart shell to reload configuration
# or
dotfiles link      # Relink configuration files
```

## Maintenance

- **Update dotfiles**: `dotfiles update`
- **Check system health**: `dotfiles doctor`
- **Clean broken symlinks**: `dotfiles clean`
- **Sync changes to remote**: `dotfiles sync`
- **View current status**: `dotfiles status`

The system automatically manages symlinks between the dotfiles repository and their target locations in the home directory.