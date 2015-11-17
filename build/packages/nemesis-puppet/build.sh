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

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
NEMESIS_PUPPET_ROOT=${BASEDIR}/../../../

docker build -t nemesis-puppet -f Dockerfile.release ${BASEDIR}
CONTAINER_ID=$(docker run -d -v ${NEMESIS_PUPPET_ROOT}:/nemesis-puppet -v ${NEMESIS_PUPPET_ROOT}/dist:/dist nemesis-puppet)
docker wait ${CONTAINER_ID}
docker rm -f ${CONTAINER_ID}
docker rmi -f nemesis-puppet
