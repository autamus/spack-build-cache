#!/bin/bash

set -e

# We should already be in cloned repository and branch!
ls .

printf "GitHub Actor: ${GITHUB_ACTOR}\n"
git config --global user.name "github-actions"
git config --global user.email "github-actions@users.noreply.github.com"
git config pull.rebase false

ls .
git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git add docs
git add docs//*
git add docs/*
git status

ls .
ls docs/

set +e
git status | grep -e "modified" -e "new"
if [ $? -eq 0 ]; then
    set -e
    printf "Changes\n"
    git commit -m "Automated push to update build cache $(date '+%Y-%m-%d')" || exit 0
    git pull origin ${INPUT_BRANCH} || printf "Does not exist yet.\n"
    git push origin ${INPUT_BRANCH} || exit 0
else
    set -e
    printf "No changes\n"
fi
