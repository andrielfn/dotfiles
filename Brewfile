# =============================================================================
# BREWFILE
# =============================================================================
# Single Brewfile for all machines (repo root). Dev/infra CLIs (gh, jq, yq, difftastic, gum,
# flyctl, hcloud, just) live in mise (config/mise/config.toml). brew keeps system
# libs, services, shell-core, interactive hot-path tools, and GUI casks.

# --- Core utilities ---------------------------------------------------------
brew "coreutils"
brew "curl"
brew "wget"
brew "openssl@3"
brew "cmake"
brew "autoconf"
brew "tree"
brew "parallel"
brew "pv"
brew "fswatch"

# --- Modern CLI replacements ------------------------------------------------
brew "bat"           # cat
brew "eza"           # ls
brew "fd"            # find
brew "ripgrep"       # grep
brew "fzf"           # fuzzy finder
brew "zoxide"        # cd
brew "ncdu"          # du
brew "duf"           # df
brew "prettyping"    # ping
brew "trash", link: true

# --- Shell & prompt ---------------------------------------------------------
brew "starship"
brew "atuin"
brew "direnv"
brew "zsh-syntax-highlighting"

# --- Git & version control --------------------------------------------------
brew "git"
brew "git-delta"
brew "git-lfs"       # required by [filter "lfs"] in gitconfig-work

# --- Development & runtimes -------------------------------------------------
brew "mise"          # runtime/tool manager (must stay in brew)
brew "postgresql@18", restart_service: :changed

# --- Infra / cloud ----------------------------------------------------------
brew "ansible"

# --- Networking -------------------------------------------------------------
brew "tailscale"
brew "nmap"

# --- Backup & storage -------------------------------------------------------
brew "restic"        # used by bin/backup + launchd backup job
brew "s3cmd"

# --- Media & documents ------------------------------------------------------
brew "ffmpeg"
brew "librsvg"
brew "webp"

# --- Fonts ------------------------------------------------------------------
cask "font-jetbrains-mono"

# --- Core applications ------------------------------------------------------
cask "1password"
cask "1password-cli"
cask "raycast"
cask "ghostty"             # terminal
cask "zed@preview"         # editor
cask "claude"
cask "docker-desktop"      # cask "docker" was renamed upstream
cask "tableplus"
cask "yaak"                # API client
cask "google-chrome"
cask "spotify"
cask "notion"
cask "notion-calendar"
cask "cleanshot"           # screenshots/annotation
cask "shottr"              # screenshots (lightweight)
cask "flux-app"            # screen color temperature

# --- Communication ----------------------------------------------------------
cask "discord"
cask "telegram"
cask "whatsapp"
cask "slack"
cask "zoom"

# --- Productivity & misc ----------------------------------------------------
cask "granola"             # meeting notes
cask "mimestream"          # email
cask "linear"              # issue tracking
cask "screen-studio"       # screen recording
cask "karabiner-elements"  # keyboard remapping
cask "daisydisk"           # disk visualizer
cask "nordvpn"
