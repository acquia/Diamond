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

# Download and import the Cassandra GPG keys used to sign the release and deb mirror
curl -s  https://dist.apache.org/repos/dist/release/cassandra/KEYS | gpg --import -
gpg --export --armor | sudo apt-key add -

# Add the Cassandra package mirror
echo "deb http://www.apache.org/dist/cassandra/debian ${DEB_VERSION} main" > /etc/apt/sources.list.d/cassandra.list

# Update and download the cassandra deb package
apt-get update -y
apt-get download cassandra

# If in a VM copy then deb file over
if [ -d "/dist/" ]; then
  mv -f *.deb /dist/
fi
