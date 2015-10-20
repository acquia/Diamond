#!/bin/bash
#
# Copyright 2014 Acquia, Inc.
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
#
# Build all packages and containers used within the nemesis-puppet manifests
#
# Usage:
# 	build-all.sh
#
set -e

if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
 echo "Error: GITHUB_OAUTH_TOKEN environment variable not set"
 exit 1
fi

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Build all packages
/bin/bash ${BASEDIR}/packages/build.sh

# Build all containers
/bin/bash ${BASEDIR}/containers/build.sh

# Remove any containers that have a status of 'Exited' and are left behind
if [[ "$(docker ps -a | grep Exited | wc -l)" -gt "0" && "$DEBUG" != 1 ]]; then
  docker rm $(docker ps -a | grep Exited | awk '{print $1}')
fi
