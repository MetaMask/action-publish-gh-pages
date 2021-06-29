#!/usr/bin/env bash

set -x
set -e
set -o pipefail

DIRECTORY="${1}"
export PREFIX=${2}
export NEW_VERSION="${GITHUB_HEAD_REF#$PREFIX}"

if [[ -z $DIRECTORY ]]; then
  echo "Error: No Directory specified."
  exit 1
fi

git config user.name github-actions
git config user.email github-actions@github.com

yarn setup
if git checkout --orphan gh-pages
  then
    git reset --hard
    git commit --allow-empty -m "Initial gh-pages commit"
    echo "Created branch gh-pages"
  else
    echo "gh-pages branch already created"
fi

git worktree add $DIRECTORY gh-pages
yarn build
cd $DIRECTORY
git add --all
git commit -m "gh-pages deploy - ${NEW_VERSION}"
git push -f origin gh-pages
