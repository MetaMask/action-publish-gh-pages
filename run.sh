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

yarn "${NPM_COMMAND}"
git remote set-url origin https://git:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git
npx gh-pages --dist "${DIRECTORY}" --message "gh-pages deploy - ${NEW_VERSION}" || abort "gh-pages failed to deploy"
