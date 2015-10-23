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

# Download and build the Acquia grid-api container. Assumes Acquia Github keys
# are available on the system performing the build.
set -ex

: ${GIT_TAG:=master}

# Attempt to read the Github OAuth token from the global .gitconfig
GITHUB_OAUTH_TOKEN=$(git config --global github.token) || true

if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
 echo "Error: GITHUB_OAUTH_TOKEN environment variable not set"
 exit 1
else
  export GITHUB_OAUTH_TOKEN="${GITHUB_OAUTH_TOKEN}"
fi

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
SRCDIR=${BASEDIR}/src

# Download the grid-api source
mkdir -p ${SRCDIR}
curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -sSL https://api.github.com/repos/acquia/grid-api/tarball/${GIT_TAG} | tar -xz --strip 1 -C ${SRCDIR}

# Build the grid-api application
cd ${SRCDIR}
make release

# Create the scratch container the grid-api application will run in
cd ${BASEDIR}
mv ${SRCDIR}/dist/grid-api ${BASEDIR}/
docker build -t grid-api -f Dockerfile.release

# Cleanup
rm -rf ${SRCDIR}
rm grid-api

