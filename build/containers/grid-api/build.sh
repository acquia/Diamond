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

: ${GIT_TAG:=master}

if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
 echo "Error: GITHUB_OAUTH_TOKEN environment variable not set"
 exit 1
fi

mkdir -p grid-api
curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -sSL https://api.github.com/repos/acquia/grid-api/tarball/${GIT_TAG} | tar -xz --strip 1 -C grid-api

cd grid-api
make docker-release
