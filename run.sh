#!/usr/bin/env bash

set -x
set -e
set -o pipefail

SOURCE_DIRECTORY="${1}"
RELEASE_BRANCH_PREFIX="${2}"
PACKAGE_BUILD_COMMAND="${3}"
DESTINATION_DIRECTORY="${4}"

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
fi

git config user.name github-actions
git config user.email github-actions@github.com
yarn "${PACKAGE_BUILD_COMMAND}"

if git checkout --orphan gh-pages
  then
    git reset --hard
    git commit --allow-empty -m "Initial gh-pages commit"
    git push -f origin gh-pages
    git checkout "$(git branch --show-current)"
    echo "Created branch gh-pages"
  else
    echo "gh-pages branch already created"
fi


git remote set-url origin "https://git:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

npx gh-pages@3.0.0 \
  "$ADD" \
  --dist "${SOURCE_DIRECTORY}" \
  --dest "${NEW_VERSION}" \
  --message "gh-pages deploy - ${NEW_VERSION}"
