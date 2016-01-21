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

set -ex

: ${NEMESIS_PUPPET_RELEASE:=""}
: ${NEMESIS_PUPPET_REPO:="acquia/nemesis-puppet"}
: ${NEMESIS_PUPPET_BRANCH:="master"}
: ${GITHUB_OAUTH_TOKEN:=""}
: ${PACKAGE_DIST_DIR:=/dist}

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

docker build --no-cache -t nemesis-puppet -f Dockerfile.build ${BASEDIR}

docker run -i --rm \
  -e "NEMESIS_PUPPET_RELEASE=${NEMESIS_PUPPET_RELEASE}" \
  -e "NEMESIS_PUPPET_REPO=${NEMESIS_PUPPET_REPO}" \
  -e "NEMESIS_PUPPET_BRANCH=${NEMESIS_PUPPET_BRANCH}" \
  -e "GITHUB_OAUTH_TOKEN=${GITHUB_OAUTH_TOKEN}" \
  -e "PACKAGE_DIST_DIR=${PACKAGE_DIST_DIR}" \
  --volumes-from nemesis-puppet-volumes \
  nemesis-puppet

docker rmi -f nemesis-puppet
