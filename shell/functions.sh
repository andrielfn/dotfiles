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

# Port management
port-kill() {
  if [[ -z "$1" ]]; then
    echo "Usage: port-kill <port-number>"
    return 1
  fi

  local port="$1"
  local pid=$(lsof -ti:$port)

  if [[ -n "$pid" ]]; then
    echo "Kill process $pid on port $port?"
    read -q "confirm?[y/N] " || { echo; return 0; }
    echo
    kill "$pid" 2>/dev/null
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
      echo "Process did not terminate, sending SIGKILL..."
      kill -9 "$pid"
    fi
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
  local selected
  selected=$(ps aux | grep "$process_name" | grep -v grep | fzf --height 40% --reverse)
  if [[ -z "$selected" ]]; then
    return 0
  fi

  local pid
  pid=$(echo "$selected" | awk '{print $2}')
  echo "Kill process $pid? ($(echo "$selected" | awk '{print $11}'))"
  read -q "confirm?[y/N] " || { echo; return 0; }
  echo
  kill "$pid" 2>/dev/null
  sleep 1
  if kill -0 "$pid" 2>/dev/null; then
    echo "Process did not terminate, sending SIGKILL..."
    kill -9 "$pid"
  fi
  echo "Process $pid killed"
}

# =============================================================================
# FILE SYSTEM FUNCTIONS
# =============================================================================

# Extract any archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

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

# Weather function
weather() {
  curl -s "wttr.in/$1?format=3"
}

# System cleanup
cleanup() {
  echo "Cleaning up system..."
  brew cleanup
  brew autoremove
  gem cleanup
  mix deps.clean --unused
  docker system prune -f
  echo "System cleanup complete!"
}
