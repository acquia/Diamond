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
# Packages Statsgod, a simple daemon for easy stats aggregation
#
set -ex

NAME="statsgod"

apt-get update -y
apt-get install -y build-essential
apt-get install -y dh-make debhelper cdbs python-support
apt-get install -y curl mercurial

# Set up golang
export GO_VERSION=1.4.1
curl -sSL https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar -C /usr/lib/ -xz && \
	mkdir -p /usr/share/go
export GOROOT=/usr/lib/go
export GOPATH=/usr/share/go
export PATH=${GOROOT}/bin:${GOPATH}/bin:$PATH

BASEDIR=${GOPATH}/src/github.com/acquia/${NAME}
rm -rf ${BASEDIR}
mkdir -p ${BASEDIR}

git clone git@github.com:acquia/statsgod.git ${BASEDIR}

go get github.com/mattn/gom

# Build the binary and setup the install package paths
cd ${BASEDIR}
make deb

# If we're in a VM, let's copy the deb file over
if [ -d "/dist/" ]; then
  mv -f ${BASEDIR}/../${NAME}*.deb /dist/
fi

rm -rf ${BASEDIR}/
