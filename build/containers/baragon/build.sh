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
#
# Build Baragon and its release containers
set -ex

: ${BARAGON_GIT_TAG:=acquia-master}

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Build the baragon jars
docker build --no-cache -t nemesis/baragon -f Dockerfile.build ${BASEDIR}
docker run -i --rm -v $BASEDIR:/dist -e "BARAGON_GIT_TAG=${BARAGON_GIT_TAG}" nemesis/baragon /package.sh

# Build the final baragon containers
docker build --no-cache -t acquia/baragon-master -f Dockerfile.baragon-master ${BASEDIR}
docker build --no-cache -t acquia/baragon-agent -f Dockerfile.baragon-agent ${BASEDIR}

# Cleanup
docker rmi -f nemesis/baragon
rm -f baragon-*.jar
