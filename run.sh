#!/usr/bin/env bash

set -x
set -e
set -o pipefail

DIRECTORY="${1}"
CURRENT_BRANCH=$(git branch --show-current)
PREFIX=${2}
NPM_COMMAND=${3}
NEW_VERSION="${GITHUB_HEAD_REF#$PREFIX}"

if [[ -z $DIRECTORY ]]; then
  echo "Error: No Directory specified."
  exit 1
fi

git config user.name github-actions
git config user.email github-actions@github.com

if git checkout --orphan gh-pages
  then
    git reset --hard
    git commit --allow-empty -m "Initial gh-pages commit"
    git checkout "${CURRENT_BRANCH}"
    echo "Created branch gh-pages"
  else
    echo "gh-pages branch already created"
fi

git worktree add "${DIRECTORY}" gh-pages
yarn "${NPM_COMMAND}"
cd "${DIRECTORY}"
TMP_PATH=$(mktemp -d)
cp -r . ${TMP_PATH}/${NEW_VERSION}/
cp -r ${TMP_PATH}/${NEW_VERSION}/ ${NEW_VERSION}/
git add --all
git commit -m "gh-pages deploy - ${NEW_VERSION}"
git push -f origin gh-pages
