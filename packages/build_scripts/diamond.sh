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
set -ex

NAME="diamond"
VERSION=3.1.1
BUILD_VERSION=acquia1

BASEDIR=/tmp/${NAME}
rm -rf ${BASEDIR}
mkdir -p ${BASEDIR}

apt-get update -y
apt-get install -y build-essential
apt-get install -y dh-make debhelper devscripts cdbs python-support

git clone https://github.com/acquia/Diamond.git ${BASEDIR}

# Build the binary and setup the install package paths
cd ${BASEDIR}
dch -v ${VERSION}~${BUILD_VERSION} -u low --maintmaint \
  "Acquia package builder <engineering@acquia.com> $(date -R)"
dpkg-buildpackage -b -d -tc -uc

# If we're in a VM, let's copy the deb file over
if [ -d "/dist/" ]; then
  mv -f ${BASEDIR}/../${NAME}*.deb /dist/
fi

rm -rf ${BASEDIR}
