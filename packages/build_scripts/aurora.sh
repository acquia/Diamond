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
# Packages Aurora for distribution
#
# Builds the set of packages that installs the Aurora executor and the scheduler
#
# This should only be used to generate snapshot builds for testing
# Normal Aurora clusters should just use the packages from upstream
# @todo: Replace this with the docker build process once it's merged upstream

set -ex
GRADLE_VERSION=2.6

# Install Java 8
apt-get update && apt-get install -y \
  debhelper \
  wget \
  unzip \
  bison \
  curl \
  git \
  libapr1-dev \
  libcurl4-openssl-dev \
  libsvn-dev \
  python-all-dev \
  software-properties-common
add-apt-repository ppa:openjdk-r/ppa -y
apt-get update && apt-get install -y openjdk-8-jdk

# Install gradle
git clone git@github.com:benley/gradle-packaging.git
cd gradle-packaging
./gradle-mkdeb.sh ${GRADLE_VERSION}
dpkg -i gradle*.deb
cd ..

# Install thrift
curl -O http://people.apache.org/~jfarrell/thrift/0.9.1/contrib/deb/ubuntu/12.04/thrift-compiler_0.9.1_amd64.deb
dpkg -i thrift-compiler_0.9.1_amd64.deb

git clone https://git-wip-us.apache.org/repos/asf/aurora-packaging.git
cp aurora-packaging/builder/deb/ubuntu-trusty/pants.ini /
git clone git@github.com:acquia/aurora.git -b aurora-1095
cd aurora
ln -s ../aurora-packaging/specs/debian debian
dpkg-buildpackage -uc -b -tc
cd ..

# If we're in a VM, let's copy the deb file over
if [ -d "/dist/" ]; then
  mv -f *.deb /dist/
fi
