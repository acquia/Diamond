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

# Build Baragon

set -ex

: ${GIT_TAG:=master}

GITHUB_OAUTH_TOKEN=$(git config --global github.token) || true

if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
 echo "Error: GITHUB_OAUTH_TOKEN environment variable not set"
 exit 1
else
  export GITHUB_OAUTH_TOKEN="${GITHUB_OAUTH_TOKEN}"
fi

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

docker build -t acquia/baragonagentbase-aurora:latest -f Dockerfile-base .

docker run --rm -it  -v $BASEDIR:/dist \
                     -v $(pwd)/resources/package.sh:/package.sh \
                     -e GIT_TAG=$GIT_TAG \
                     -e GITHUB_OAUTH_TOKEN=${GITHUB_OAUTH_TOKEN} \
                     acquia/baragonagentbase-aurora:latest /package.sh

docker build -t acquia/baragonservice-master:latest -f Dockerfile-master-release $BASEDIR
docker build -t acquia/baragonservice-agent:latest  -f Dockerfile-agent-release  $BASEDIR

# Cleanup
docker rmi acquia/baragonagentbase-aurora:latest
rm Baragon*.jar
