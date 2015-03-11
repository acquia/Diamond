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
# Script to download the latest Apache Cassandra debian package. Latest stable version
# in the 21x repo is 2.1.0
#
set -ex

DEB_VERSION="21x"
# This needs to be kept in sync with the Cassandra module
PACKAGE_VERSION='2.1.3'

# Add the Cassandra deb repo and download and import the Cassandra GPG keys
echo "deb http://www.apache.org/dist/cassandra/debian ${DEB_VERSION} main" > /etc/apt/sources.list.d/cassandra.list
curl -L -s https://dist.apache.org/repos/dist/release/cassandra/KEYS | sudo apt-key add -

# Add the Datastax deb repo and download and import the Datastax GPG keys
echo "deb http://debian.datastax.com/community stable main" > /etc/apt/sources.list.d/datastax.list
curl -L -s https://debian.datastax.com/debian/repo_key | sudo apt-key add -

apt-get update -y

# Download the cassandra deb package
apt-get download cassandra=$PACKAGE_VERSION

# Download Datastax OPS center
apt-get download opscenter datastax-agent

# If in a VM copy then deb file over
if [ -d "/dist/" ]; then
  mv -f *.deb /dist/
fi
