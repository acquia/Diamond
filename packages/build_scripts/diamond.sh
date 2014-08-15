#!/usr/bin/env bash
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