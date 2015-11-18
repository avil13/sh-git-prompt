#!/bin/sh

# This script is an attempt to generate a git-prompt with only sh
myTrim() {
    echo $1 | sed 's/^\s*//;s/\s*$//'
}

BuildGitPrompt() {

    local GitPrompt=""

    # colors
    local gpColReset='\033[0m'
    local gpColDelimiters='\033[38;5;202m'
    if [ "x$(git symbolic-ref HEAD 2>&1 | grep fatal)" == "x" ]
    then
        # we are in a git repo

        # format
        local gpPrefix="${gpColDelimiters}{"
        local gpSuffix="${gpColDelimiters}}$gpColReset "
        local gpSeparator="${gpColDelimiters}|"
        #prefixes
        local gpFormatBranch="\033[38;5;5m"
        local gpFormatAhead="\033[38;5;39m ↑"
        local gpFormatBehind="\033[38;5;196m ↓"
        local gpFormatEqual="\033[38;5;46m ✔"
        local gpFormatStaged="\033[38;5;48m ●"
        local gpFormatEdit="\033[38;5;27m ✚"
        local gpFormatDel="\033[38;5;160m ✖"
        local gpFormatUntracked="\033[38;5;214m ?"

        # staged changes
        local gpCountStaged=$(myTrim "$(git diff --name-status --staged | wc -l)")

        # unstaged changes
        local gpUnstaged=$(myTrim "$(git diff --name-status | cut -c 1)")
        local gpCountModified=$(myTrim $(echo "$gpUnstaged" | grep -c M))
        local gpCountDeleted=$(myTrim $(echo "$gpUnstaged" | grep -c D))
        local gpCountUntracked=$(myTrim "$(git ls-files -o --exclude-standard | wc -l)")

        # commits differences
        local gpBranch="$(git branch | grep --color=never '*' | tail -c +3)"
        # default if upstream doesn't exist
        local gpAhead="$(git rev-list HEAD --not --remotes | wc -l)"
        local gpBehind="0"
        git show-ref --verify --quiet refs/remotes/origin/${gpBranch}
        local gpUpExists=$?
        # if the remote branch exists, compare to it
        [ $gpUpExists -eq 0 ] && gpAhead=$(git rev-list HEAD --not origin/${gpBranch} | wc -l)
        [ $gpUpExists -eq 0 ] && gpBehind=$(git rev-list origin/${gpBranch} --not ${gpBranch} | wc -l)
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

    echo -ne "${GitPrompt}"
}

PrintPrompt() {
    echo -ne "$(BuildGitPrompt)"
}

# for bash
if [ -z "$PROMPT_COMMAND" ]
then
    PROMPT_COMMAND=PrintPrompt
else
    PROMPT_COMMAND="${PROMPT_COMMAND};PrintPrompt"
fi

# adapt for other shells !
