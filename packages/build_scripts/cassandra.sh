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
# in the 20x repo is 2.0.9
#
set -x

DEB_VERSION="20x"

# Download and import the Cassandra GPG keys used to sign the release and deb mirror
curl -s  http://www.apache.org/dist/cassandra/KEYS | gpg --import -
gpg --export --armor | sudo apt-key add -

# Add the Cassandra package mirror
echo "deb http://www.apache.org/dist/cassandra/debian ${DEB_VERSION} main" > /etc/apt/sources.list.d/cassandra.list

# Update and download the cassandra deb package
apt-get update -qq
apt-get -qq download cassandra

# Clean up
rm /etc/apt/sources.list.d/cassandra.list
apt-get update -qq

# If in a VM copy then deb file over
if [ -d "/vagrant/" ]; then
  mkdir -p /vagrant/dist
  mv -f *.deb /vagrant/dist/
fi