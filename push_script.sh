#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

function log {
    local message="$1"
    local color="$2"

    case "$color" in
        'RED'|'GREEN'|'LIGHT_BLUE'|'NC') ;;
        *) color='NC';;
    esac

    echo -e "${!color}$message${NC}"
}

function prompt_user {
    read -r input < /dev/tty
    if [[ -z "$input" ]]; then
        log "Invalid input. Please provide a non-empty value." 'RED'
        exit 1
    fi
    echo -e "$input"
}

function git_pull {
    log "Pulling the latest changes from the main branch of repository " 'GREEN'
    git pull < /dev/tty

    if [ $? -ne 0 ]; then
      log "Error during git pull request. Do you want to resolve conflicts? (y/n)" 'RED'
      read -r conflicts
      if [ "$conflicts" == "y" ]; then 
        resolve_conflicts
      else
        log "Conflicts unresolved fix before pushing again" 'RED'
        exit 1
      fi
    fi
}

function resolve_conflicts {
    log "Attempting to resolve conflicts using git stash..." 'RED'
    git stash
    git pull

    if [ $? -ne 0 ]; then
        log "Unable to resolve conflicts, pull failed. Resolve conflicts manually and try again." 'RED'
        exit 1
    else
        git stash pop
        log "Conflicts temporarily resolved. Check popped files before trying again (changes may have stacked up and you need to manually discard unwanted changes)" 'GREEN'
    fi
}

function git_commit_and_push {
    git add "$file_to_push"

    git commit -m "$type_commit($scope_commit) File $file_to_push:" -m "$description_commit"

    if [ $? -eq 0 ]; then
        git push
        log "Changes successfully pushed to repository: " 'GREEN'
        log "Commit: $type_commit($scope_commit): \"$description_commit\"" 'LIGHT_BLUE'
        exit 0
    else
        log "Error during commit. Resolve conflicts and try again." 'RED'
        exit 1
    fi
}

function validate_commit_type {
    for x in add fix refactor performance style test docs build_tool other; do
        if [ "$x" = "$type_commit" ]; then
            return 0
        fi
    done
    return 1
}

git_pull

log "Current Git Status:" 'LIGHT_BLUE'
git status

if [[ -z $(git status -s) ]]; then 
  log "No changes to commit." 'RED'
  exit 1
fi

log "Specify one or multiple files to be pushed: " 'LIGHT_BLUE'
file_to_push=`prompt_user`

log "Specify the TYPE of the commit, argument must be one of [add, fix, refactor, performance, style, test, docs, build_tool, other]: " 'LIGHT_BLUE'
type_commit=`prompt_user`

if ! validate_commit_type; then
    log "Type specified is not part of existing types. Please enter a valid type." 'RED'
    exit 1
fi

log "Specify the SCOPE of the commit (what area of the code is the commit related to):" 'LIGHT_BLUE' 
scope_commit=`prompt_user`

log "${LIGHT_BLUE}Specify a DESCRIPTION for the commit\nFinal commit will be of format ${NC}<type>(scope): [description]: " 'LIGHT_BLUE' 
description_commit=`prompt_user`

log "Do you want to push the changes to the main branch? (y/n):" 'LIGHT_BLUE' 
read confirm_push
if [ "$confirm_push" != "y" ]; then
    log "Pushing sequence aborted. Exiting."
    exit 0
fi

git_commit_and_push
