#!/bin/sh

# This script is an attempt to generate a git-prompt with only sh

BuildGitPrompt() {

    local GitPrompt=""

    # colors
    local gpColReset='\033[0m'
    local gpColDelimiters='\e[38;5;202m'
    if [ "x$(git symbolic-ref HEAD 2>&1 | grep fatal)" == "x" ]
    then
        # we are in a git repo

        # format
        local gpPrefix="${gpColDelimiters}{"
        local gpSuffix="${gpColDelimiters}}$gpColReset "
        local gpSeparator="${gpColDelimiters}|"
        #prefixes
        local gpFormatBranch="\e[38;5;5m"
        local gpFormatAhead="\e[38;5;39m↑"
        local gpFormatBehind="\e[38;5;196m↓"
        local gpFormatEqual="\e[38;5;46m✔"
        local gpFormatStaged="\e[38;5;48m●"
        local gpFormatEdit="\e[38;5;27m✚"
        local gpFormatDel="\e[38;5;160m✖"
        local gpFormatUntracked="\e[38;5;214m?"

        # staged changes
        local gpCountStaged=`git diff --name-status --staged | wc -l`

        # unstaged changes
        local gpUnstaged="$(git diff --name-status | cut -c 1)"
        local gpCountModified=$(echo "$gpUnstaged" | grep -c M)
        local gpCountDeleted=$(echo "$gpUnstaged" | grep -c D)
        local gpCountUntracked=$(git ls-files -o --exclude-standard | wc -l)

        # commits differences
        local gpBranch="$(git branch | grep --color=never '*' | tail -c +3)"
        local gpDiff="$(git rev-list --left-right origin/${gpBranch}...HEAD)"
        local gpAhead=$(echo "$gpDiff" | grep -c '>')
        local gpBehind=$(echo "$gpDiff" | grep -c '<')

        # Formatting
        local gpFirstHalf=""

        if [ $gpAhead != "0" ]
        then
            gpFirstHalf="${gpFormatAhead}${gpAhead}"
        fi
        if [ $gpBehind != "0" ]
        then
            gpFirstHalf="${gpFirstHalf}${gpFormatBehind}${gpBehind}"
        fi
        if [ "x${gpFirstHalf}" = "x" ]
        then
            gpFirstHalf="${gpFormatEqual}"
        fi

        gpFirstHalf="${gpPrefix}${gpFormatBranch}${gpBranch}${gpFirstHalf}"

        gpSecondHalf=""
        if [ $gpCountStaged != "0" ]
        then
            gpSecondHalf="${gpFormatStaged}${gpCountStaged}"
        fi
        if [ $gpCountModified != "0" ]
        then
            gpSecondHalf="${gpSecondHalf}${gpFormatEdit}${gpCountModified}"
        fi
        if [ ${gpCountDeleted} != "0" ]
        then
            gpSecondHalf="${gpSecondHalf}${gpFormatDel}${gpCountDeleted}"
        fi
        if [ ${gpCountUntracked} != "0" ]
        then
            gpSecondHalf="${gpSecondHalf}${gpFormatUntracked}${gpCountUntracked}"
        fi

        if [ "x${gpSecondHalf}" = "x" ]
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
        GitPrompt="\e[38;5;27m($(basename "${VIRTUAL_ENV}"))${ResetColor} ${GitPrompt}"
    fi

    echo -ne "${GitPrompt}"
}

PrintPrompt() {
    local dir="$(pwd -P)"
    [[ "$dir" =~ ^"$HOME"(/|$) ]] && dir="~${dir#$HOME}"
    echo -ne "$(BuildGitPrompt)\e[38;5;34m$(whoami)\e[38;5;202m@\e[38;5;27m$(uname -n)\e[38;5;202m:${dir}\n"
    export PS1="\[\e[38;5;202m\]~>\[\e[38;5;15m\] "
    export PS2="\[\e[38;5;202m\]>\[\e[28;5;15m\] "
}

# for bash
if [ -z "$PROMPT_COMMAND" ]
then
    PROMPT_COMMAND=PrintPrompt
else
    PROMPT_COMMAND="${PROMPT_COMMAND};PrintPrompt"
fi

# adapt for other shells !
