# # OS X trash (`brew install trash`) util.
# function rm() {
#   trash $1
# }

delete_old_branches() {
  # Set default value for age limit
  local age_limit=${1:-30}

  # Get the current date in epoch time
  local current_date=$(date +%s)

  # List all branches and iterate over them
  git for-each-ref --sort=committerdate refs/heads/ --format='%(refname:short) %(committerdate:unix)' | while read branch last_commit_date
  do
    # Calculate the age of the branch
    local branch_age=$(( (current_date - last_commit_date) / 86400 )) # 86400 seconds in a day

    # Check if the branch is older than the specified limit
    if [ "$branch_age" -gt "$age_limit" ]; then
      # Delete the branch
      echo "Deleting branch: $branch"
      git branch -D "$branch"
    fi
  done
}


function prs() {
  GH_FORCE_TTY=100% gh pr list | fzf --height 90% --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window down --header-lines 3 | awk '{print $1}' | xargs gh pr view --web
}

function prco() {
  GH_FORCE_TTY=100% gh pr list | fzf --height 50% --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window down --header-lines 3 | awk '{print $1}' | xargs gh pr view --web
}

# function gco() {
#   git bb | fzf --ansi --height 40% --layout=reverse --border | awk '{print $1}' | xargs git checkout
# }

function fzf-git-branch() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    git branch --all --color=always --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi --layout=reverse --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
        sed "s/.* //"
}

function fzf-git-checkout() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    local branch

    branch=$(fzf-git-branch)
    if [[ "$branch" = "" ]]; then
        echo "No branch selected."
        return
    fi

    # If branch name starts with 'remotes/' then it is a remote branch. By
    # using --track and a remote branch name, it is the same as:
    # git checkout -b branchName --track origin/branchName
    if [[ "$branch" = 'remotes/'* ]]; then
        git checkout --track $branch
    else
        git checkout $branch;
    fi
}

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
    python3 -m http.server "$port"
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

# Convert RAW images to 2560px max-dimension JPEG @ 80 quality to ./output
# check for presence of convert command first:
if [ -x "$(which convert)" ]; then
  function convert-raw-to-jpg() {
    local quality=${1:-80};
    local max_dim=${2:-2650};
    local source_files=${3:-*.NEF};
    echo "Usage: convert-raw-to-jpg [quality=80] [max-dimension-px=2560] [source=*.NEF]";
    echo "Converting all ${source_files} to JPEG (${quality} quality, ${max_dim}px max) to output/...";
    mkdir -p output 2> /dev/null;
    find . -type f -iname "${source_files}" -print0 | xargs -0 -n 1 -P 8 -I {} convert -verbose -units PixelsPerInch {} -colorspace sRGB -resize ${max_dim}x${max_dim} -set filename:new '%t-%wx%h' -density 72 -format JPG -quality ${quality} 'output/%[filename:new].jpg';
    echo 'Done.';
  }
fi;
