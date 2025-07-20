# Dotfiles

Cross-platform dotfiles system with environment-aware configuration management and automated installation.

## New MacBook Setup

For a new MacBook, follow these steps:

1. **Install Command Line Tools:**
   ```bash
   xcode-select --install
   ```

2. **Clone this repository:**
   ```bash
   git clone https://github.com/andrielfn/dotfiles ~/.dotfiles
   cd ~/.dotfiles
   ```

3. **Run the setup script:**
   
   For personal machine (default):
   ```bash
   ./setup.sh
   ```
   
   For work machine:
   ```bash
   ./setup.sh --machine-type=work
   ```
   
   For work machine with custom directory:
   ```bash
   ./setup.sh --machine-type=work --work-dir=Company
   ```

4. **Select Full Setup** when prompted for complete environment configuration.

5. **Configure environment-specific settings** (see Configuration section below).

6. **Restart your terminal** to activate the new configuration.

## Machine Setup Options

The setup script automatically configures your machine based on the type specified:

**Machine Types:**
- **Personal** (default): Creates `~/Code/` directory for personal projects
- **Work**: Creates work directory (default `~/Work/`) and enables work-specific features like 1Password CLI

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
├── shell/                 # Shell library files (sourced by zshrc)
│   ├── aliases.sh         # Command aliases
│   ├── functions.sh       # Shell functions
│   ├── exports.sh         # PATH manipulation and shell-specific logic
│   └── init.sh           # Tool initialization and environment loading
├── bin/                   # Executable commands
│   └── dotfiles          # Main management utility
├── env/                   # Environment-specific configurations
│   ├── personal/         # Personal environment (~/Code/)
│   ├── work/            # Work environment (~/Work/)
│   └── shared/          # Shared configurations and environment variables
├── installers/           # Installation scripts
├── scripts/             # Setup utilities
└── setup.sh            # Main installation script
```

## Dotfiles Management

The `dotfiles` command provides centralized management:

```bash
dotfiles edit      # Open dotfiles in $EDITOR
dotfiles update    # Pull latest changes and relink configurations
dotfiles link      # Link all configurations from mapping file
dotfiles status    # Show current dotfiles status
dotfiles doctor    # Check for common issues
dotfiles reload    # Reload shell configuration
dotfiles clean     # Remove broken symlinks
dotfiles sync      # Commit and push changes
dotfiles help      # Show available commands
```

## Environment Detection

The system automatically detects and configures environments based on working directory:

- **Personal Environment**: Projects in `~/Code/` use personal git configuration
- **Work Environment**: Projects in work directory (default `~/Work/`, configurable) use work git configuration and enable work-specific features

Environment-specific configurations are loaded automatically when the shell initializes. Work machines automatically:
- Enable 1Password CLI integration (if installed)
- Load work-specific environment variables
- Use work git configuration

## Configuration

### Environment Variables

The system loads environment variables in this order:
1. Shared public variables (`env/shared/env-shared`)
2. Shared secrets (`env/shared/env-secrets`)
3. Environment-specific public variables (`env/personal/env-personal` or `env/work/env-work`)
4. Environment-specific secrets (`env/personal/env-secrets` or `env/work/env-secrets`)

**Shared Secrets** - Copy `env/shared/env-secrets.example` to `env/shared/env-secrets` and add your secrets:

```bash
cp env/shared/env-secrets.example env/shared/env-secrets
# Edit env/shared/env-secrets with secrets that apply to both environments
```

**Environment-Specific Secrets** - Copy the example files and add environment-specific secrets:

```bash
# For personal secrets
cp env/personal/env-secrets.example env/personal/env-secrets

# For work secrets  
cp env/work/env-secrets.example env/work/env-secrets
```

**Public Environment Variables** - Edit the tracked environment files directly:

- Shared: `env/shared/env-shared`
- Personal: `env/personal/env-personal`
- Work: `env/work/env-work`

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
- `env/shared/env-shared` - Shared environment variables

After editing shell files, run `dotfiles reload` to restart your shell.
After editing config files, run `dotfiles link` to update symlinks.

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

**Global Settings** - Edit `env/shared/.gitconfig`

### Tool Management

Development tools are managed through Mise. Install tools as needed:

```bash
mise use erlang@latest
mise use elixir@latest
mise use node@latest
```

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