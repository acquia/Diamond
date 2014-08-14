#!/usr/bin/env bash
#
# Packages tablesnap for s3 backup of Cassandra sstables
#

NAME="apt-transport-s3"
VERSION="1.1.1"

OS=$(lsb_release -cs)
ARCH=$(uname -m)

if [ "$ARCH" = "i686" ]; then
  ARCH="i386"
fi

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