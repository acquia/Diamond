#!/bin/bash
set -e

: ${GIT_TAG:=master}

SRC_DIR=/usr/share/go/src/github.com/acquia/grid-api

# Download the source and build it
mkdir -p ${SRC_DIR}
curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -sSL https://api.github.com/repos/acquia/grid-api/tarball/${GIT_TAG} | tar -xz --strip 1 -C ${SRC_DIR}
cd ${SRC_DIR}
make

if [ -d "/dist/" ]; then
  cp /usr/share/go/bin/grid-api /dist
fi
