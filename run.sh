#!/usr/bin/env bash

set -x
set -o pipefail

SOURCE_DIRECTORY="${1}"
RELEASE_BRANCH_PREFIX="${2}"
PACKAGE_BUILD_COMMAND="${3}"
DESTINATION_DIRECTORY="${4}"
CURRENT_BRANCH=$(git branch --show-current)

if [[ -z $SOURCE_DIRECTORY ]]; then
  echo "Error: No source directory specified."
  exit 1
fi

if [[ -z $RELEASE_BRANCH_PREFIX ]]; then
  echo "Error: No release branch prefix specified."
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

NEW_VERSION="${GITHUB_HEAD_REF#"$RELEASE_BRANCH_PREFIX"}"

if [[ -z $NEW_VERSION ]]; then
  echo "Error: Failed to extract new version from release branch name."
  exit 1
fi

if [[ -z $NEW_VERSION ]]; then
  echo "Error: Failed to extract new version from release branch name."
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
  # Edit package.json in place to reflect the new homepage url
fi

git config user.name github-actions
git config user.email github-actions@github.com
git remote set-url origin "https://git:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

yarn "${PACKAGE_BUILD_COMMAND}"
branch_exists=$(git ls-remote --quiet . origin/gh-pages)

if [ -n "${branch_exists}" ]
  then
    echo "gh-pages branch already created"
  else
    git checkout --orphan gh-pages
    git reset --hard

    git commit --allow-empty -m "Initial gh-pages commit"
    git checkout "${CURRENT_BRANCH}"
    echo "Created branch gh-pages"  
fi

if [ -n "${ADD}" ]
  then
    echo ""
  else
    npx json -I -f package.json -e "this.homepage=this.homepage + \"${DESTINATION_DIRECTORY}/\""
fi

npx gh-pages@3.0.0 \
  "$ADD" \
  --dist "${SOURCE_DIRECTORY}" \
  --dest "${DESTINATION_DIRECTORY}" \
  --message "gh-pages deploy - ${NEW_VERSION}"
