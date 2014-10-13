#!/bin/bash -xe
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
# Script to clone down and build a package for Tessera:
# "Tessera is a front-end interface for Graphite, which provides a large
# selection of presentations, layout, and interactivity options for building
# dashboards.
# The biggest key differences between Tessera and other frontends are the
# separation of queries from presentations, and the ability to apply arbitrary
# transformations to the presentations & queries, allowing for a large degree
# of interactivity. Tessera is initially focused on information presentation -
# it does not NOT address the areas of metric discovery or query composition
# (although it may in the future)."
# https://github.com/urbanairship/tessera
NAME="tessera"
VERSION="0.1.0"
DEB_BUILD_VERSION="1"

OS=$(lsb_release -cs)
ARCH=$(uname -m)

BASEDIR=/opt/tessera

# Disable host key checking for github since pip doesnt allow the flags for
# -oStrictHostKeyChecking=no
cp -a /home/vagrant/.ssh /root/.ssh
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
chmod -R 600 /root/.ssh

apt-get install -y git python-virtualenv python-pip python-dev npm nodejs-legacy

git clone git@github.com:urbanairship/tessera.git $BASEDIR
cd $BASEDIR
virtualenv $BASEDIR
source ${BASEDIR}/bin/activate
pip install -r requirements.txt
npm install -g grunt-cli
npm install
grunt

deactivate
cd ~/
fpm -t deb -s dir \
  -a all \
  -a ${ARCH} \
  --vendor "Acquia, Inc." \
  --provides "tessera" \
  --depends "python" \
  --depends "python-virtualenv" \
  -n ${NAME} \
  -v ${VERSION}-${DEB_BUILD_VERSION}~${OS} \
  -m "hosting-eng@acquia.com" \
  --description "Acquia ${NAME} ${VERSION} built on $(date +"%Y%m%d%H%M%S")" \
  ${BASEDIR}
