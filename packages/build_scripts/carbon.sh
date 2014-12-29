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
# Packages Carbon for distribution
#
#  This package will setup a venv for carbon to run out of /opt/graphite and
#  will install all dependencies into /opt/graphite/lib/pythonX.X/site-packages
# This should not be used to run an actual carbon instance, we're just using it for rollups on Cassandra nodes
#
set -ex

NAME="carbon"
VERSION="0.1.3"
DEB_BUILD_VERSION="0"

OS=$(lsb_release -cs)
ARCH=$(uname -m)

if [ "$ARCH" = "i686" ]; then
  ARCH="i386"
fi

BASEDIR=/opt/graphite

# Graphite python dependencies to install into the virtual env
dependencies=$( cat <<EOF
pycassa
Twisted<12.0
EOF
)

# Pip install a specified Github repo
#
# @param $1 owner
# @param $2 repo name
# @param $3 tag/branch name [default: 'master']
function gh-pip() {
  pip install git+ssh://git@github.com/${1}/${2}.git@${3:-"master"}
}

# Install the build deps needed to create the packages
apt-get update -y
apt-get install -y git python-virtualenv python-pip python-dev

# Setup the virtual env
mkdir -p $BASEDIR
virtualenv $BASEDIR
source ${BASEDIR}/bin/activate

# Install package dependencies
for dep in $dependencies
do
  pip install $dep
done

# Install any git packaged repos
gh-pip 'acquia' 'carbon' 'db-plugin'
gh-pip 'acquia' 'carbon-cassandra-plugin'

# Disable the virtual env
deactivate

# Create the deb
fpm --force -t deb -s dir \
  --deb-user www-data --deb-group www-data \
  -a ${ARCH} \
  --vendor "Acquia, Inc." \
  --provides "carbon" \
  --depends "python" \
  --depends "python-virtualenv" \
  -n ${NAME} \
  -v ${VERSION}-${DEB_BUILD_VERSION}~${OS} \
  -m "hosting-eng@acquia.com" \
  --description "Acquia ${NAME} ${VERSION} built on $(date +"%Y%m%d%H%M%S")" \
  ${BASEDIR}

# If we're in a VM, let's copy the deb file over
if [ -d "/dist/" ]; then
  mv -f *.deb /dist/
fi
