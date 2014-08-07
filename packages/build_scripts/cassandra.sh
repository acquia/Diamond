#!/bin/bash
#
# Script to download the latest Apache Cassandra debian package. Latest stable version
# in the 20x repo is 2.0.9
#
set -x

DEB_VERSION="20x"

# Download and import the Cassandra GPG keys used to sign the release and deb mirror
curl -s  http://www.apache.org/dist/cassandra/KEYS | gpg --import -
gpg --export --armor | sudo apt-key add -

# Add the Cassandra package mirror
echo "deb http://www.apache.org/dist/cassandra/debian ${DEB_VERSION} main" > /etc/apt/sources.list.d/cassandra.list

# Update and download the cassandra deb package
apt-get update -qq
apt-get -qq download cassandra

# Clean up
rm /etc/apt/sources.list.d/cassandra.list
apt-get update -qq

# If in a VM copy then deb file over
if [ -d "/vagrant/" ]; then
  mkdir -p /vagrant/dist
  mv -f *.deb /vagrant/dist/
fi