# Dirs
# ====
alias code="cd ~/code"
alias sublconf="cd ~/Library/Application\ Support/Sublime\ Text\ 3"
alias ptec="cd ~/ptec"

# Config
# ======
alias reload="source ~/.bash_profile && echo 'Bash reloaded! :D'"

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
alias s="spring"
alias rdm="bin/rake db:migrate"
alias rdr="bin/rake db:rollback"
alias rof="bin/rspec --only-failures"

# Others
# ======
alias marked="open -a Marked"
alias dotfiles="subl ~/.dotfiles"
alias t="ruby -I'lib:test'"

# Go
# alias gb="go build"
# alias gg="go get"
# alias gr="go run"
# alias goc="cd $GOPATH/src/github.com/andrielfn"

# Docker
# ======
alias ds="/Applications/Docker/Docker\ Quickstart\ Terminal.app/Contents/Resources/Scripts/start.sh"
alias dc="docker-compose"

# Deamons
# =======
alias rethinkdb.start='launchctl load ~/Library/LaunchAgents/homebrew.mxcl.rethinkdb.plist'
alias rethinkdb.stop='launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.rethinkdb.plist'

alias mongodb.start='launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist'
alias mongodb.stop='launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist'

alias redis.start='launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist'
alias redis.stop='launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.redis.plist'
