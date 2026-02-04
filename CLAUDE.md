# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive dotfiles management system that provides cross-platform configuration with environment-aware setup (personal vs work machines). The system uses a centralized configuration mapping approach with automated installation and management.

## Architecture

### Core Components

- **Configuration Mapping System**: All config files are centrally managed through `config/mapping.cfg`
- **Environment Detection**: Automatically detects personal vs work environments based on directory structure
- **Shell Library**: Modular shell configuration split across `shell/` directory
- **Automated Setup**: Complete environment setup through `setup.sh` with installer modules

### Directory Structure

- `config/` - All configuration files managed by the mapping system
- `shell/` - Shell library files (aliases, functions, exports, init)
- `env/` - Environment-specific configurations (personal/work/shared)
- `bin/` - Executable scripts (main `dotfiles` command)
- `installers/` - Modular installation scripts
- `scripts/` - Setup utilities and helper functions

## Common Commands

### Setup and Installation
```bash
# Initial setup (personal machine)
./setup.sh

# Work machine setup
./setup.sh --machine-type=work --work-dir=Company

# Installation options during setup:
# 1) Full Setup (Recommended) - Complete environment
# 2) Package Management Only - Homebrew and tools
# 3) Shell Configuration Only - ZSH setup
# 4) macOS Configuration Only - System preferences
```

### Daily Management
```bash
# Primary management command
dotfiles help           # Show all available commands
dotfiles edit           # Open dotfiles in $EDITOR
dotfiles update         # Pull latest changes and relink configs
dotfiles link           # Link all configurations from mapping file
dotfiles status         # Show current dotfiles status
dotfiles reload         # Reload shell configuration (restarts shell)
dotfiles doctor         # Check for common issues
dotfiles clean          # Remove broken symlinks
dotfiles sync           # Commit and push changes
```

### Configuration Management
```bash
# After editing config files
dotfiles link           # Relink configurations

# After editing shell files
dotfiles reload         # Restart shell to reload

# Check system health
dotfiles doctor
dotfiles status
```

## Environment System

### Environment Detection
- **Personal**: Detected when only `~/Code/` directory exists
- **Work**: Detected when `~/Work/` or `~/work/` directory exists
- Custom work directories supported via setup script

### Configuration Loading Order
1. `env/shared/env-shared` - Shared public variables
2. `env/shared/env-secrets` - Shared secrets (not tracked)
3. `env/personal/env-personal` or `env/work/env-work` - Environment-specific public
4. `env/personal/env-secrets` or `env/work/env-secrets` - Environment-specific secrets

### Git Configuration
- Shared config: `env/shared/.gitconfig` (linked to `~/.gitconfig`)
- Personal config: `env/personal/.gitconfig-personal` (used in `~/Code/`)
- Work config: `env/work/.gitconfig-work` (used in work directories)

## Tool Management

- **Package Management**: Homebrew with environment-specific Brewfiles
- **Runtime Management**: Mise (modern replacement for asdf)
- **Shell Enhancement**: Oh My Zsh, Starship prompt, Zoxide, FZF
- **Search Tools**: Ripgrep with global configuration to ignore build/dependency directories
- **Development Tools**: Automatically configured based on environment

## Configuration Mapping

All configuration files are managed through `config/mapping.cfg`:
```
source_file:destination_path
zshrc:~/.zshrc
starship.toml:~/.starship.toml
ripgrep:~/.ripgreprc        # Global ripgrep configuration
zed/:~/.config/zed/         # Directory mapping (trailing slash)
```

The ripgrep configuration (`config/ripgrep`) automatically ignores common build and dependency directories like `deps/`, `_build/`, `node_modules/`, `target/`, and many others.

## Development Workflow

1. Edit configuration files in `config/` directory
2. Run `dotfiles link` to update symlinks
3. For shell changes, run `dotfiles reload`
4. Use `dotfiles status` and `dotfiles doctor` for health checks
5. Commit changes with `dotfiles sync`

## Key Files

- `bin/dotfiles:257` - Main management command with all subcommands
- `setup.sh:24-45` - Command line argument parsing for machine setup
- `shell/init.sh:6-12` - Environment detection logic
- `config/mapping.cfg` - Central configuration mapping
- `shell/` directory - All shell library components

## Environment Variables

Local customizations should go in `~/.zshrc.local` (not tracked), while tracked environment variables should be placed in the appropriate `env/` files based on scope (shared vs personal/work).