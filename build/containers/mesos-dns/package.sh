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
SRC_PATH="/usr/share/go/src/github.com/mesosphere/mesos-dns"
MESOS_DNS_RELEASE=$1

mkdir -p ${SRC_PATH}
curl -sSL https://github.com/mesosphere/mesos-dns/tarball/${MESOS_DNS_RELEASE} | tar -xz --strip 1 -C ${SRC_PATH}
cd ${SRC_PATH}
CGO_ENABLED=0 godep go build -a -installsuffix cgo -o /dist/mesos-dns .


