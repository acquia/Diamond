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
# Packages Diamond for system metric collection
#

NAME="diamond"

BASEDIR=/tmp/${NAME}
mkdir -p ${BASEDIR}

apt-get install -y build-essential
apt-get install -y dh-make debhelper cdbs python-support

git clone git@github.com:acquia/Diamond.git ${BASEDIR}

# Build the binary and setup the install package paths
cd ${BASEDIR}
dpkg-buildpackage -b -d -tc

# If we're in a VM, let's copy the deb file over
if [ -d "/vagrant/" ]; then
  mkdir -p /vagrant/dist
  mv -f ${BASEDIR}/../${NAME}*.deb /vagrant/dist/
fi

rm -rf ${BASEDIR}