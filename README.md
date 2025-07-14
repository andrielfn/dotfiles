# Dotfiles

Modern dotfiles setup with environment-specific configurations and automated installation.

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/andrielfn/dotfiles ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the setup script:

   ```bash
   ./setup.sh
   ```

3. Choose installation type:

   - **Full Setup**: Complete environment setup
   - **Package Management Only**: Homebrew and development tools
   - **Shell Configuration Only**: Enhanced shell only
   - **macOS Configuration Only**: System preferences only

4. Restart your terminal or run:
   ```bash
   source ~/.zshrc
   ```

## Project Structure

```
dotfiles/
├── env/                    # Environment-specific configurations
│   ├── personal/          # Personal environment (~/Code/)
│   ├── work/             # Work environment (~/Work/)
│   └── shared/           # Shared configurations
├── installers/           # Installation scripts
├── configs/              # Configuration files
├── bin/                 # Custom scripts
└── setup.sh            # Main installation script
```

## Environment Detection

The system automatically detects your environment based on directory:

- **Personal**: `~/Code/` projects use personal git config
- **Work**: `~/Work/` projects use work git config

## Tool Management

Mise is configured for development tools but doesn't auto-install. Install manually:

```bash
mise use erlang@latest
mise use elixir@latest
```

## Configuration

### Environment Variables

**Global Secrets** - Add to `~/.zshrc.local` (not tracked by git):

```bash
export GLOBAL_API_KEY="secret_key"
export SHARED_TOKEN="token_here"
```

**Environment-Specific Secrets** - Add to secret files (not tracked by git):

- Personal secrets: `env/personal/env-secrets`
- Work secrets: `env/work/env-secrets`

Copy the example files and rename them:

```bash
cp env/personal/env-secrets.example env/personal/env-secrets
cp env/work/env-secrets.example env/work/env-secrets
```

```bash
# Example: env/personal/env-secrets
export GITHUB_TOKEN="personal_token_here"
export PERSONAL_API_KEY="secret_key"
```

**Public Environment Variables** - Add to tracked environment files:

- Personal: `env/personal/env-personal`
- Work: `env/work/env-work`

```bash
# Example: env/personal/env-personal
export PERSONAL_PROJECT_PATH="$HOME/Code/my-project"
export DEVELOPMENT_MODE="true"
```

### ZSH Configuration

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

**Modify Core Config** - Edit `configs/shell/zshrc` and relink:

```bash
cd ~/.dotfiles
# Edit configs/shell/zshrc
./installers/shell.sh
```

### Git Configuration

**Personal Settings** - Edit `env/personal/.gitconfig-personal`:

```bash
[user]
    name = "Your Name"
    email = "personal@email.com"
    signingkey = "your_gpg_key"
```

**Work Settings** - Edit `env/work/.gitconfig-work`:

```bash
[user]
    name = "Your Name"
    email = "work@company.com"
    signingkey = "work_gpg_key"
```

**Global Git Config** - Edit `env/shared/.gitconfig`

### Aliases and Functions

**Add New Aliases** - Edit `configs/shell/aliases.sh`:

```bash
# Add your aliases
alias myalias="command"
alias shortcut="long command here"
```

**Add New Functions** - Edit `configs/shell/functions.sh`:

```bash
# Add your functions
my_function() {
    echo "Hello from my function"
}
```

### Apply Changes

```bash
source ~/.zshrc
# or restart terminal
```
