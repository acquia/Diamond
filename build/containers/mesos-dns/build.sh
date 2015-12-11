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
# Builds a Docker image containing mesos-dns.

set -ex

# Get the directory where this script is located;
# WARNING this will fail if you run this script from a symlink
CURDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

: ${MESOS_DNS_RELEASE:=v0.4.0}
: ${MESOS_DNS_TAG:=acquia/mesos-dns:$MESOS_DNS_RELEASE}
: ${MESOS_DNS_LATEST_TAG:=acquia/mesos-dns:latest}
: ${MESOS_DNS_BUILDER_TAG:=mesos-dns-builder}

# Create the builder container
docker build --no-cache -t ${MESOS_DNS_BUILDER_TAG} -f ${CURDIR}/Dockerfile.build ${CURDIR}

# Run the build
docker run -it --rm -v ${CURDIR}:/dist ${MESOS_DNS_BUILDER_TAG} /bin/bash package.sh ${MESOS_DNS_RELEASE}
docker rmi -f ${MESOS_DNS_BUILDER_TAG}

# Package the build in a minimal scratch container
docker build --no-cache -t ${MESOS_DNS_TAG} -f ${CURDIR}/Dockerfile.release ${CURDIR}

# Clean up intermediate file
rm ${CURDIR}/mesos-dns
