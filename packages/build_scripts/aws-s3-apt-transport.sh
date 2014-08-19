#!/usr/bin/env bash
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
# Packages tablesnap for s3 backup of Cassandra sstables
#

NAME="apt-transport-s3"
VERSION="1.1.1"

BASEDIR=/tmp/apt-s3
mkdir -p ${BASEDIR}

apt-get install -y build-essential g++ libapt-pkg-dev libcurl4-openssl-dev
apt-get install -y dh-make debhelper cdbs

git clone https://github.com/jfarrell/apt-s3.git ${BASEDIR}

# Build the binary and setup the install package paths
cd ${BASEDIR}
dpkg-buildpackage -b -d -tc

# If we're in a VM, let's copy the deb file over
if [ -d "/vagrant/" ]; then
  mkdir -p /vagrant/dist
  mv -f ${BASEDIR}/../${NAME}*.deb /vagrant/dist/
fi

# Cleanup
rm -rf ${BASEDIR}