#!/usr/bin/env bash

set -x
set -e
set -o pipefail

DIRECTORY="${1}"
CURRENT_BRANCH=$(git branch --show-current)
PREFIX=${2}
NPM_COMMAND=${3}
DESTINATION=${4}
NEW_VERSION="${GITHUB_HEAD_REF#$PREFIX}"

if [[ -z $DIRECTORY ]]; then
  echo "Error: No Directory specified."
  exit 1
fi

if [[ -z $DESTINATION ]]; then
  echo "Error: No Destination specified."
  exit 1
fi

git config user.name github-actions
git config user.email github-actions@github.com

yarn "${NPM_COMMAND}"
npx gh-pages --dist "${DIRECTORY}" --message "gh-pages deploy - ${NEW_VERSION}" || abort "gh-pages failed to deploy"
