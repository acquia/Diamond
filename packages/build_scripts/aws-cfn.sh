#!/bin/bash
#
# Script to convert the AWS CloudFormation bootstrap tools from a python tar archive
# into a deb package
#
set -x

# Download the latest AWS CloudFormation bootstrap tools
curl -s -O https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz

# Get the named package including actual version from the archive
PKG_NAME=$(tar -ztf aws-cfn-bootstrap-latest.tar.gz | egrep '^[^/]+/?$' | sed 's/\/$//')

# Extract the archive and create the deb
tar -xzvf aws-cfn-bootstrap-latest.tar.gz
fpm -s python -t deb --no-python-fix-name ${PKG_NAME}

# If in a VM copy then deb file over
if [ -d "/vagrant/" ]; then
  mv -f *.deb /vagrant/
fi