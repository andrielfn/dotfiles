#!/usr/bin/env zsh

# Configs
#
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="[%F{yellow}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%f]"

GIT_PS1_SHOWDIRTYSTATE="1"
GIT_PS1_SHOWSTASHSTATE="1"
GIT_PS1_SHOWUNTRACKEDFILES="1"
GIT_PS1_SHOWUPSTREAM="auto verbose git"
GIT_PS1_SHOWCOLORHINTS="1"

ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%F{red}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%F{yellow}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%F{green}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%F{red}"

# Set required options
#
setopt PROMPT_SUBST

# Load required modules
#
# autoload -Uz vcs_info

# Set vcs_info parameters
#
# zstyle ':vcs_info:*' enable hg bzr git
# zstyle ':vcs_info:*:*' unstagedstr '!'
# zstyle ':vcs_info:*:*' stagedstr '+'
# zstyle ':vcs_info:*:*' formats "$FX[bold]%r/%S" "(%b)" "%%u%c"
# zstyle ':vcs_info:*:*' actionformats "$FX[bold]%r/%S" "%b" "%u%c (%a)"
# zstyle ':vcs_info:*:*' nvcsformats "%~" "" ""

# Fastest possible way to check if repo is dirty
#
git_dirty() {
  # Check if we're in a git repo
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  # Check if it's dirty
  command git diff --quiet --ignore-submodules HEAD &>/dev/null; [ $? -eq 1 ] && echo "*"
}

# Display information about the current repository
#
repo_information() {
  # echo "%F{blue}${vcs_info_msg_0_%%/.} %F{green}$vcs_info_msg_1_`git_dirty` $vcs_info_msg_2_%f"
  echo "%F{blue}%~%f"
}

# Displays the exec time of the last command if set threshold was exceeded
#
cmd_exec_time() {
  local stop=`date +%s`
  local start=${cmd_timestamp:-$stop}
  let local elapsed=$stop-$start
  [ $elapsed -gt 5 ] && echo ${elapsed}s
}

# Get the initial timestamp for cmd_exec_time
#
preexec() {
  cmd_timestamp=`date +%s`
}

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Only proceed if there is actually a commit.
        if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal") == 0 ]]; then
            # Get the last commit.
            last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
            now=`date +%s`
            seconds_since_last_commit=$((now-last_commit))

            # Totals
            MINUTES=$((seconds_since_last_commit / 60))
            HOURS=$((seconds_since_last_commit/3600))

            # Sub-hours and sub-minutes
            DAYS=$((seconds_since_last_commit / 86400))
            SUB_HOURS=$((HOURS % 24))
            SUB_MINUTES=$((MINUTES % 60))

            if [[ -n $(git status -s 2> /dev/null) ]]; then
                if [ "$MINUTES" -gt 30 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
                elif [ "$MINUTES" -gt 10 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
                else
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
                fi
            else
                COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            fi

            if [ "$HOURS" -gt 24 ]; then
                echo "[$COLOR${DAYS}d%{$reset_color%}]"
            elif [ "$MINUTES" -gt 60 ]; then
                echo "[$COLOR${HOURS}h%{$reset_color%}]"
            else
                echo "[$COLOR${MINUTES}m%{$reset_color%}]"
            fi
        else
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            echo "[$COLOR~]"
        fi
    fi
}


# Output additional information about paths, repos and exec time
#
precmd() {
  # vcs_info # Get version control info before we start outputting stuff
  print -P "\n$(repo_information) %F{green}$(__git_ps1 "%s") %F{yellow}$(cmd_exec_time)%f"
}

# Define prompts
#
PROMPT="%(?.%F{green}.%F{red})➜%f " # Display a red prompt char on failure
RPROMPT='$(git_time_since_commit) $(git_prompt_short_sha)%f'

# ------------------------------------------------------------------------------
#
# List of vcs_info format strings:
#
# %b => current branch
# %a => current action (rebase/merge)
# %s => current version control system
# %r => name of the root directory of the repository
# %S => current path relative to the repository root directory
# %m => in case of Git, show information about stashes
# %u => show unstaged changes in the repository
# %c => show staged changes in the repository
#
# List of prompt format strings:
#
# prompt:
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)
#
# ------------------------------------------------------------------------------
