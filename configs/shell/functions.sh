# =============================================================================
# DEVELOPMENT FUNCTIONS
# =============================================================================

# Environment detection
detect_environment() {
  if [[ "$PWD" == *"/Work/"* ]] || [[ "$PWD" == *"/work/"* ]]; then
    echo "work"
  else
    echo "personal"
  fi
}

# Load environment-specific configuration
load_env_config() {
  local env=$(detect_environment)
  local dotfiles_path="$HOME/.dotfiles"

  # Load public environment variables
  if [[ -f "$dotfiles_path/env/$env/env-$env" ]]; then
    source "$dotfiles_path/env/$env/env-$env"
  fi

  # Load secret environment variables (not tracked by git)
  if [[ -f "$dotfiles_path/env/$env/env-secrets" ]]; then
    source "$dotfiles_path/env/$env/env-secrets"
  fi
}

# Git functions
fzf-git-checkout() {
  local branch
  branch=$(git branch --all | grep -v HEAD | fzf --height 40% --reverse | sed 's/^..//' | sed 's/remotes\/origin\///')
  if [[ -n "$branch" ]]; then
    git checkout "$branch"
  fi
}

# Quick git commit with conventional commits
gcom() {
  if [[ -z "$1" ]]; then
    echo "Usage: gcom <type> <message>"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    return 1
  fi

  local type="$1"
  shift
  local message="$*"

  git add . && git commit -m "$type: $message"
}

# Create new branch and push to remote
gnb() {
  if [[ -z "$1" ]]; then
    echo "Usage: gnb <branch-name>"
    return 1
  fi

  git checkout -b "$1"
  git push -u origin "$1"
}

# =============================================================================
# ELIXIR/PHOENIX FUNCTIONS
# =============================================================================

# Run specific test file with watch
mtw() {
  if [[ -z "$1" ]]; then
    echo "Usage: mtw <test-file>"
    return 1
  fi

  find . -name "*$1*" -type f | head -1 | xargs mix test --listen-on-stdin
}

# =============================================================================
# PRODUCTIVITY FUNCTIONS
# =============================================================================

# System information
sysinfo() {
  echo "🖥️  System Information"
  echo "==================="
  echo "OS: $(uname -s)"
  echo "Kernel: $(uname -r)"
  echo "Architecture: $(uname -m)"
  echo "Hostname: $(hostname)"
  echo "Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
  echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
  echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
  echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
  echo "Shell: $SHELL"
  echo "Terminal: $TERM"

  echo ""
  echo "🔧 Development Tools"
  echo "==================="
  echo "Git: $(git --version)"
  echo "Elixir: $(elixir --version | head -1)"
  echo "Erlang: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell)"
  echo "Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
  echo "Docker: $(docker --version 2>/dev/null || echo 'Not installed')"
}

# Port management
port-kill() {
  if [[ -z "$1" ]]; then
    echo "Usage: port-kill <port-number>"
    return 1
  fi

  local port="$1"
  local pid=$(lsof -ti:$port)

  if [[ -n "$pid" ]]; then
    kill -9 "$pid"
    echo "Process on port $port killed"
  else
    echo "No process found on port $port"
  fi
}

# Find and kill process by name
proc-kill() {
  if [[ -z "$1" ]]; then
    echo "Usage: proc-kill <process-name>"
    return 1
  fi

  local process_name="$1"
  ps aux | grep "$process_name" | grep -v grep | fzf --height 40% --reverse | awk '{print $2}' | xargs kill -9
}

# =============================================================================
# FILE SYSTEM FUNCTIONS
# =============================================================================

# Create directory and cd into it
mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi

  mkdir -p "$1" && cd "$1"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# =============================================================================
# STARTUP FUNCTIONS
# =============================================================================

# Initialize shell environment
init_shell() {
  # Load environment-specific configuration
  load_env_config

  # Initialize tools if available
  if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
  fi

  if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
  fi

  if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
  fi

  # Set up FZF key bindings
  if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
  fi
}
