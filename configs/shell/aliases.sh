# =============================================================================
# SYSTEM ALIASES
# =============================================================================

# Directory shortcuts
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias work="cd ~/Work"
alias code="cd ~/Code"
alias dotfiles="cd ~/Code/dotfiles"

# Modern replacements for common commands
alias ls="eza --icons"
alias ll="eza -lhbgH --git --icons"
alias la="eza -lhbgHa --git --icons"
alias lt="eza --tree --level=2 --icons"
alias cat="bat"
alias grep="rg"
alias find="fd"
alias ping="prettyping --nolegend"
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias top="htop"
alias df="duf"

# Safe operations
alias rm="trash"
alias cp="cp -i"
alias mv="mv -i"

# =============================================================================
# DEVELOPMENT ALIASES
# =============================================================================

# Git shortcuts
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gap="git add --patch"
alias gb="git branch"
alias gbd="git branch -d"
alias gbD="git branch -D"
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gcam="git commit --amend -m"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gds="git diff --staged"
alias gf="git fetch"
alias gl="git log --oneline --graph --decorate"
alias gll="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gm="git merge"
alias gp="git push"
alias gpl="git pull"
alias gpr="git pull --rebase"
alias gr="git reset"
alias grh="git reset --hard"
alias grs="git reset --soft"
alias gs="git status"
alias gst="git stash"
alias gstp="git stash pop"
alias gstl="git stash list"
alias gt="git tag"
alias gw="git worktree"

# GitHub CLI
alias ghpr="gh pr create"
alias ghprs="gh pr status"
alias ghprv="gh pr view"
alias ghprc="gh pr checkout"
alias ghprm="gh pr merge"
alias ghrepo="gh repo view --web"

# =============================================================================
# ELIXIR/PHOENIX ALIASES
# =============================================================================

# Mix shortcuts
alias m="mix"
alias mc="mix compile"
alias mcw="mix compile --warnings-as-errors"
alias mcc="mix compile --force"
alias md="mix deps"
alias mdg="mix deps.get"
alias mdc="mix deps.compile"
alias mdu="mix deps.update"
alias mdr="mix deps.tree"

# Testing
alias mt="mix test"
alias mta="mix test --trace"
alias mtf="mix test --failed"
alias mtw="mix test --stale"
alias mts="mix test --seed"
alias mtc="mix test --cover"
alias mtr="mix test --repeat"

# Ecto database
alias mec="mix ecto.create"
alias med="mix ecto.drop"
alias mem="mix ecto.migrate"
alias mer="mix ecto.rollback"
alias mes="mix ecto.setup"
alias mep="mix ecto.reset"
alias megs="mix ecto.gen.migration"
alias megd="mix ecto.gen.schema"

# IEx shortcuts
alias i="iex"
alias im="iex -S mix"
alias px="iex -S mix phx.server"

# Elixir formatting and analysis
alias mf="mix format"
alias mfc="mix format --check-formatted"
alias mc="mix credo"
alias mcs="mix credo --strict"
alias md="mix dialyzer"
alias mps="mix phx.digest"

# =============================================================================
# UTILITY ALIASES
# =============================================================================

# Network
alias lip="ipconfig getifaddr en0"
alias lipa="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias ports="lsof -i -P | grep LISTEN"

# System
alias reload="exec $SHELL -l"
alias path='echo -e ${PATH//:/\\n}'
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# SSH
alias key="cat ~/.ssh/id_ed25519.pub | pbcopy && echo 'SSH key copied to clipboard!'"
alias sshkey="cat ~/.ssh/id_ed25519.pub"

# Security
alias genpwd="openssl rand -base64 32 | pbcopy && echo 'Strong password copied to clipboard!'"
alias genkey="openssl rand -hex 32 | pbcopy && echo 'Random key copied to clipboard!'"

# =============================================================================
# PRODUCTIVITY ALIASES
# =============================================================================

# Quick edits
alias zshrc="$EDITOR ~/.zshrc"
alias zshreload="source ~/.zshrc"
alias hosts="sudo $EDITOR /etc/hosts"

# FZF enhanced commands
alias fzf-files='fd --type f --hidden --follow --exclude .git | fzf --preview "bat --color=always --style=header,grid --line-range :300 {}"'
alias fzf-dirs='fd --type d --hidden --follow --exclude .git | fzf --preview "eza --tree --level=2 --icons {}"'
alias fzf-git='git log --oneline --graph --color=always | fzf --ansi --preview "git show --color=always {1}"'
alias fzf-kill='ps aux | fzf --header-lines=1 | awk "{print \$2}" | xargs kill'

# Docker (if used)
alias d="docker"
alias dc="docker-compose"
alias dcup="docker-compose up"
alias dcdown="docker-compose down"
alias dcb="docker-compose build"
alias dcr="docker-compose run --rm"

# =============================================================================
# FUNCTIONS AS ALIASES
# =============================================================================

# Quick directory creation and navigation
mkcd() {
  mkdir -p "$1" && cd "$1"
}

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
