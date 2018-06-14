# Dirs
# ====
alias code="cd ~/code"
alias sublconf="cd ~/Library/Application\ Support/Sublime\ Text\ 3"
alias ptec="cd ~/ptec"

# Config
# ======
alias reload=". ~/.zshrc && echo 'ZSH reloaded! :D'"

# Shell
# =====
alias ll="ls -FGlahs"
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep --color=auto"
alias ls="ls -G"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias lip="ipconfig getifaddr en0"
alias key="cat ~/.ssh/id_rsa.pub | pbcopy; echo 'SSH key copied to clipboard!'"
alias chunk="curl -s -T - chunk.io | pbcopy; echo 'URL copied to clipboard!'"
alias hex="openssl rand -hex"
alias fd='find . -type d -name'
alias ff='find . -type f -name'

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

# Others
# ======
alias t="tree -I '.git|node_modules|bower_components|.DS_Store' --dirsfirst --filelimit 15 -L ${1:-3} -aC $2"
alias marked="open -a Marked"
alias dotfiles="subl ~/.dotfiles"
# alias t="ruby -I'lib:test'"
alias g="git"
alias matatodomundo="ps aux | pgrep -lf 'rack|spring|rails|ruby|puma|sneakers' | awk '{print $1}' | xargs kill -9 && echo 🔪"

# Go
# alias gb="go build"
# alias gg="go get"
# alias gr="go run"
# alias goc="cd $GOPATH/src/github.com/andrielfn"