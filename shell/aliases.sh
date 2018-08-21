# Dirs
# ====
# alias code="cd ~/code"
alias sublconf="cd ~/Library/Application\ Support/Sublime\ Text\ 3"

# Config
# ======
alias reload=". ~/.zshrc && echo 'ZSH reloaded! :D'"

# Shell
# =====
alias tree="exa -T -I '.git|node_modules|bower_components|.DS_Store' --group-directories-first"
alias marked="open -a Marked"
alias dotfiles="subl ~/code/dotfiles"
alias g="git"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias matatodomundo="ps aux | pgrep -lf 'rack|spring|rails|ruby|puma|sneakers|unicorn' | awk '{print $1}' | xargs kill -9 && echo 🔪"
alias ll="exa -lhbgH --git"
alias ll="exa -lhbgHa --git"
alias ls="exa"
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep --color=auto"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias lip="ipconfig getifaddr en0"
alias key="cat ~/.ssh/id_rsa.pub | pbcopy; echo 'SSH key copied to clipboard!'"
alias chunk="curl -s -T - chunk.io | pbcopy; echo 'URL copied to clipboard!'"
alias hex="openssl rand -hex"
alias genpwd="openssl rand -base64 16 | pbcopy; echo 'Password copied to clipboard!'"
alias fd='find . -type d -name'
alias ff='find . -type f -name'
alias cat='bat'
alias ping='prettyping --nolegend'
alias prev="fzf --preview 'bat --color always {}'"
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias help='tldr'

# Show/hide hidden files in Finder
# ================================
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Bundler
# =======
alias b="bundle"
alias bi="b install --jobs=2"
alias bu="b update"
alias be="b exec"
alias bo="b open"

# Rails
# =====
alias rc="bin/rails c"
alias rs="bin/rails s"
alias s="bin/spring"
alias sr="bin/rspec"
alias st="bin/teaspoon"
alias rdm="bin/rake db:migrate"
alias rdr="bin/rake db:rollback"
alias rof="bin/rspec --only-failures"

# Go
# alias gb="go build"
# alias gg="go get"
# alias gr="go run"
# alias goc="cd $GOPATH/src/github.com/andrielfn"
