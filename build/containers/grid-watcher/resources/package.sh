#!/bin/bash
set -e

: ${GRID_WATCHER_GIT_REPO:="acquia/grid-watcher"}
: ${GRID_WATCHER_GIT_TAG:=master}

SRC_DIR=/usr/share/go/src/github.com/acquia/grid-watcher

# Hijack git checkout for acquia repos and add in the private oauth token so `gom install` can install code from our private repos
git config --global url."https://${GITHUB_OAUTH_TOKEN}:x-oauth-basic@github.com/acquia/".insteadOf "https://github.com/acquia/"

# Download the source and build it
mkdir -p ${SRC_DIR}
git clone -b ${GRID_WATCHER_GIT_TAG} https://${GITHUB_OAUTH_TOKEN}:x-oauth-basic@github.com/${GRID_WATCHER_GIT_REPO}.git ${SRC_DIR}
cd ${SRC_DIR}
make grid-watcher

if [ -d "/dist/" ]; then
  cp /usr/share/go/bin/grid-watcher /dist
fi
