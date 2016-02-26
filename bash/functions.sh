# # OS X trash (`brew install trash`) util.
# function rm() {
#   trash $1
# }

# Open a project in my own GitHub
function ghopen() {
  open "https://github.com/andrielfn/${1}";
}

# Get the process on a given port
function port() {
  lsof -i ":${1:-80}"
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
    local port="${1:-8000}"
    python -m SimpleHTTPServer "$port"
}

# Build a Go project and then run it
function gox {
  go install && ${PWD##*/}
}

# Determine size of a file or total size of a directory
function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* *;
  fi;
}

# Create a directory and cd to it
function mkcd {
  mkdir -p "$1" && cd "$1"
}

# Get the current branch
function parse_git_branch {
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Get the ruby version name using rbenv
function rb-version {
  rbenv version-name 2>/dev/null
}

# A function to extract correctly any archive based on extension
# USE: extract imazip.zip
#      extract imatar.tar
# from:
# https://github.com/flatiron-school/dotfiles/blob/3fc97f6a48580dd1fde71dde6634029156af2810/bash_profile#L115-L136
function extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)  tar xjf $1      ;;
      *.tar.gz)   tar xzf $1      ;;
      *.bz2)      bunzip2 $1      ;;
      *.rar)      rar x $1        ;;
      *.gz)       gunzip $1       ;;
      *.tar)      tar xf $1       ;;
      *.tbz2)     tar xjf $1      ;;
      *.tgz)      tar xzf $1      ;;
      *.zip)      unzip $1        ;;
      *.Z)        uncompress $1   ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
