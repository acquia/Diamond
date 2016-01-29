#!/bin/bash
#
# Copyright 2015 Acquia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Download and build the Acquia grid-watcher container. Assumes Acquia Github keys
# are available on the system performing the build.
set -ex

: ${GRID_WATCHER_GIT_TAG:=master}

if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
    # Attempt to read the Github OAuth token from the global .gitconfig
    GITHUB_OAUTH_TOKEN=$(git config --global github.token) || true
fi

if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
 echo "Error: GITHUB_OAUTH_TOKEN environment variable not set"
 exit 1
else
  export GITHUB_OAUTH_TOKEN="${GITHUB_OAUTH_TOKEN}"
fi

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Create the builder container
docker build --no-cache -t nemesis/grid-watcher -f ${BASEDIR}/Dockerfile.build ${BASEDIR}

# Run the build
docker run -it --rm \
  -e GITHUB_OAUTH_TOKEN=${GITHUB_OAUTH_TOKEN} \
  -e GRID_WATCHER_GIT_TAG=${GRID_WATCHER_GIT_TAG} \
  -v ${BASEDIR}:/dist nemesis/grid-watcher /package.sh

docker rmi -f nemesis/grid-watcher

# Package the build in a minimal scratch container
docker build --no-cache -t acquia/grid-watcher -f ${BASEDIR}/Dockerfile.release ${BASEDIR}

# Cleanup
rm grid-api
