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
# The following bash sets default values for incoming env vars;
#  see http://stackoverflow.com/a/28085062
: ${GRADLE_VERSION:=2.6}
: ${GRADLE_PACKAGING_GIT_TAG:=acquia-20151015a}
: ${AURORA_PACKAGING_GIT_TAG:=acquia-20150909a}
: ${AURORA_GIT_TAG:=aurora-1095}

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
rm -rf gradle-packaging
if [ -z $GITHUB_OAUTH_TOKEN ]; then
    git clone -b ${GRADLE_PACKAGING_GIT_TAG} git@github.com:acquia/gradle-packaging.git
else
    mkdir -p gradle-packaging
    # See http://stackoverflow.com/a/23796159
    curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -L https://api.github.com/repos/acquia/gradle-packaging/tarball/${GRADLE_PACKAGING_GIT_TAG} | tar xz --strip-components 1 -C gradle-packaging
fi
cd gradle-packaging
./gradle-mkdeb.sh ${GRADLE_VERSION}
dpkg -i gradle*.deb
cd ..

# Install thrift
curl -O http://people.apache.org/~jfarrell/thrift/0.9.1/contrib/deb/ubuntu/12.04/thrift-compiler_0.9.1_amd64.deb
dpkg -i thrift-compiler_0.9.1_amd64.deb

rm -rf aurora-packaging
if [ -z $GITHUB_OAUTH_TOKEN ]; then
    git clone -b ${AURORA_PACKAGING_GIT_TAG} git@github.com:acquia/aurora-packaging.git
else
    mkdir -p aurora-packaging
    curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -L https://api.github.com/repos/acquia/aurora-packaging/tarball/${AURORA_PACKAGING_GIT_TAG} | tar xz --strip-components 1 -C aurora-packaging
fi

cp aurora-packaging/builder/deb/ubuntu-trusty/pants.ini /

rm -rf aurora
if [ -z $GITHUB_OAUTH_TOKEN ]; then
    git clone -b ${AURORA_GIT_TAG} git@github.com:acquia/aurora.git
else
    mkdir -p aurora
    curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -L https://api.github.com/repos/acquia/aurora/tarball/${AURORA_GIT_TAG} | tar xz --strip-components 1 -C aurora
fi
cd aurora
ln -s ../aurora-packaging/specs/debian debian
dpkg-buildpackage -uc -b -tc
cd ..

# If we're in a VM, let's copy the deb file over
if [ -d "/dist/" ]; then
  mv -f *.deb /dist/
fi
