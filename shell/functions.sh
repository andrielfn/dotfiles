# =============================================================================
# DEVELOPMENT FUNCTIONS
# =============================================================================

# Git functions
fzf-git-checkout() {
  local branch
  branch=$(git branch --all | grep -v HEAD | fzf --height 40% --reverse | sed 's/^..//' | sed 's/remotes\/origin\///')
  if [[ -n "$branch" ]]; then
    git checkout "$branch"
  fi
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
