# Shell
# =====
alias reload=". ~/.zshrc && echo 'ZSH reloaded! :D'"
alias dotfiles="zed ~/.dotfiles"
alias git="hub"
alias g="git"
alias gco='fzf-git-checkout'
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias ll="exa -lhbgH --git"
alias ll="exa -lhbgHa --git"
alias ls="exa"
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep --color=auto"
# alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias lip="ipconfig getifaddr en0"
alias key="cat ~/.ssh/id_rsa.pub | pbcopy; echo 'SSH key copied to clipboard!'"
alias chunk="curl -s -T - chunk.io | pbcopy; echo 'URL copied to clipboard!'"
alias hex="openssl rand -hex 16"
alias genpwd="openssl rand -base64 16 | pbcopy; echo 'Password copied to clipboard!'"
alias fd='find . -type d -name'
alias ff='find . -type f -name'
#alias cat='bat'
alias ping='prettyping --nolegend'
alias prev="fzf --preview 'bat --color always {}'"
alias usage="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias help='tldr'
alias z="zed ."

# Show/hide hidden files in Finder
# ================================
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Elixir/Phoenix
# =====
# alias ps="mix phx.server"
alias mt="mix test"
alias mf="mix test --failed"
alias mem="mix ecto.migrate"
alias mer="mix ecto.rollback"
alias px="iex -S mix phx.server"
