#!/bin/sh

# This script is an attempt to generate a git-prompt with only sh
myTrim() {
    echo $1 | sed -e 's/^[[:space:]]*//'
}

BuildGitPrompt() {

    local GitPrompt=""

    # colors
    local gpColReset='\033[0m'
    local gpColDelimiters='\033[38;5;202m'
    # if [ "x$(git symbolic-ref HEAD 2>&1 | grep fatal)" == "x" ]
    if git rev-parse --git-dir > /dev/null 2>&1
    then
        # we are in a git repo

        # format
        local gpPrefix="${gpColDelimiters}["
        local gpSuffix="${gpColDelimiters}]$gpColReset "
        local gpSeparator="${gpColDelimiters}|"
        # prefixes
        local gpFormatBranch="\033[38;5;5m"
        local gpFormatAhead="\033[38;5;39m ↑"
        local gpFormatBehind="\033[38;5;196m ↓"
        local gpFormatEqual="\033[38;5;46m ✔"
        local gpFormatStaged="\033[38;5;48m ●"
        local gpFormatEdit="\033[38;5;27m ✚"
        local gpFormatDel="\033[38;5;160m ✖"
        local gpFormatUntracked="\033[38;5;214m ?"
        local gpFormatStashes="\033[37m ≡"
        local gpFormatUnmerged="\033[38;5;160m ⊗"

        # staged changes
        local gpCountStaged=$(myTrim "$(git diff --name-status --staged | wc -l)")

        # unstaged changes
        local gpUnstaged=$(git diff --name-status | cut -c 1)
        local gpCountModified=$(myTrim $(echo "$gpUnstaged" | grep -c M))
        local gpCountDeleted=$(myTrim $(echo "$gpUnstaged" | grep -c D))
        local gpCountUntracked=$(myTrim "$(git ls-files -o --exclude-standard | wc -l)")
        local gpCountUnmerged=$(myTrim "$(git ls-files --unmerged | cut -f2 | sort -u | wc -l)")
        # stash lines
        local countStashes=$(myTrim "$(git stash list | wc -l)")

        # commits differences
        # local gpBranch=$(myTrim "$(git branch | grep --color=never '*' | tail -c +3)")
        local gpBranch_abbr=$(git rev-parse --abbrev-ref HEAD)
        local gpBranch_hash=$(git rev-parse --short=5 HEAD)
        local gpBranch="${gpBranch_abbr} (${gpBranch_hash})"

        # default if upstream doesn't exist
        local gpAhead=$(myTrim "$(git rev-list HEAD --not --remotes | wc -l)")
        local gpBehind="0"
        git show-ref --verify --quiet refs/remotes/origin/${gpBranch}
        local gpUpExists=$?
        # if the remote branch exists, compare to it

        [ $gpUpExists -eq 0 ] && gpAhead=$(myTrim "$(git rev-list HEAD --not origin/${gpBranch} | wc -l)")
        [ $gpUpExists -eq 0 ] && gpBehind=$(myTrim "$(git rev-list origin/${gpBranch} --not ${gpBranch} | wc -l)")
        # Formatting
        local gpFirstHalf=""

        if [ $gpAhead -ne "0" ]
        then
            gpFirstHalf="${gpFormatAhead}${gpAhead}"
        fi

        if [ $gpBehind -ne "0" ]
        then
            gpFirstHalf="${gpFirstHalf}${gpFormatBehind}${gpBehind}"
        fi

        if [ "x${gpFirstHalf}" == "x" ]
        then
            gpFirstHalf="${gpFormatEqual}"
        fi

        gpFirstHalf="${gpPrefix}${gpFormatBranch}${gpBranch}${gpFirstHalf}"

        gpSecondHalf=""
        if [ "$gpCountStaged" -ne "0" ]
        then
            gpSecondHalf="${gpFormatStaged}${gpCountStaged}"
        fi

        if [ "$gpCountModified" -ne "0" ]
        then
            gpSecondHalf="${gpSecondHalf}${gpFormatEdit}${gpCountModified}"
        fi

        if [ "$gpCountDeleted" -ne "0" ]
        then
            gpSecondHalf="${gpSecondHalf}${gpFormatDel}${gpCountDeleted}"
        fi

        if [ "$gpCountUntracked" -ne "0" ]
        then
            gpSecondHalf="${gpSecondHalf}${gpFormatUntracked}${gpCountUntracked}"
        fi

        if [ "$countStashes" -ne "0" ]
        then
            gpSecondHalf="${gpSecondHalf}${gpFormatStashes}${countStashes}"
        fi

        if [ "$gpCountUnmerged" -ne "0" ]
        then
            gpSecondHalf="${gpSecondHalf}${gpFormatUnmerged}${gpCountUnmerged}"
        fi

        if [ "x${gpSecondHalf}" == "x" ]
        then
            GitPrompt="${gpFirstHalf}${gpSuffix}"
        else
            GitPrompt="${gpFirstHalf}${gpSeparator}${gpSecondHalf}${gpSuffix}"
        fi
    fi

    # detecting virtualenv
    if [[ -n "${VIRTUAL_ENV}" ]]
    then
        # we take care of printing virtualenv
        GitPrompt="\033[38;5;27m($(basename "${VIRTUAL_ENV}"))${ResetColor} ${GitPrompt}"
    fi

    echo -ne "$GitPrompt"
}


# for bash
if [ -z "$PROMPT_COMMAND" ]
then
    PROMPT_COMMAND=BuildGitPrompt
else
    PROMPT_COMMAND="${PROMPT_COMMAND};BuildGitPrompt"
fi

# adapt for other shells !
