#!/bin/bash
set -e

: ${GRID_API_GIT_TAG:=master}

SRC_DIR=/usr/share/go/src/github.com/acquia/grid-api

# Download the source and build it
mkdir -p ${SRC_DIR}
git clone -b ${GRID_API_GIT_TAG} https://${GITHUB_OAUTH_TOKEN}:x-oauth-basic@github.com/acquia/grid-api.git ${SRC_DIR}
cd ${SRC_DIR}
git fetch --tags

make

if [ -d "/dist/" ]; then
  cp /usr/share/go/bin/grid-api /dist
fi
