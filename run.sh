#!/usr/bin/env bash

set -x
set -e
set -o pipefail

SOURCE_DIRECTORY="${1}"
PACKAGE_BUILD_COMMAND="${2}"
DESTINATION_DIRECTORY="${3}"
COMMIT_MESSAGE="${4}"
CURRENT_BRANCH=$(git branch --show-current)

if [[ -z $SOURCE_DIRECTORY ]]; then
  echo "Error: No source directory specified."
  exit 1
fi

if [[ -z $PACKAGE_BUILD_COMMAND ]]; then
  echo "Error: No build command name specified."
  exit 1
fi

if [[ -z $DESTINATION_DIRECTORY ]]; then
  echo "Error: No destination directory specified."
  exit 1
fi

if [[ -z $COMMIT_MESSAGE ]]; then
  echo "Error: No commit message specified."
  exit 1
fi


# If publishing directly to the root directory, erase all existing files on the
# gh-pages branch. Otherwise, do not modify any files outside of the destination
# directory.
if [[ "$DESTINATION_DIRECTORY" = "." ]]; then
  ADD=""
else
  # "--add" prevents existing files from being deleted.
  ADD="--add"
fi

REPO="https://git:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

git config user.name github-actions
git config user.email github-actions@github.com
git remote set-url origin "$REPO"

branch_exists=$(git ls-remote --quiet --heads "$REPO" gh-pages)

if [[ -n "$branch_exists" ]]
  then
    echo "gh-pages branch already created"
  else
    git checkout --orphan gh-pages
    git reset --hard

    git commit --allow-empty -m "Initial gh-pages commit"
    git push origin gh-pages
    git checkout "${CURRENT_BRANCH}"
    echo "Created branch gh-pages"  
fi

if [[ "$ADD" = "--add" ]]
  then
    # Edit package.json in place to reflect the new homepage url
    # This is required by some build tools, e.g. Webpack
    npx json -I -f package.json \
      -e "this.homepage=(this.homepage.replace(/\/$/u, '')) + \"/${DESTINATION_DIRECTORY}/\""
fi

yarn "${PACKAGE_BUILD_COMMAND}"

npx gh-pages@3.2.3 \
  "$ADD" \
  --dist "${SOURCE_DIRECTORY}" \
  --dest "${DESTINATION_DIRECTORY}" \
  --message "${COMMIT_MESSAGE}"
