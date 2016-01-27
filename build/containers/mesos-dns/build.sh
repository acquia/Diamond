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

: ${MESOS_DNS_VERSION:=v0.5.1}

# Create the builder container
docker build --no-cache -t nemesis/mesos-dns -f ${CURDIR}/Dockerfile.build ${CURDIR}

# Run the build
docker run -it --rm -v ${CURDIR}:/dist nemesis/mesos-dns /bin/bash package.sh ${MESOS_DNS_VERSION}
docker rmi -f nemesis/mesos-dns

# Package the build in a minimal scratch container
docker build --no-cache -t acquia/mesos-dns:${MESOS_DNS_VERSION} -f ${CURDIR}/Dockerfile.release ${CURDIR}
docker tag -f acquia/mesos-dns:${MESOS_DNS_VERSION} acquia/mesos-dns:latest

# Clean up intermediate file
rm ${CURDIR}/mesos-dns
