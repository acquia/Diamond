#!/bin/bash

# Download a specific version of Apahce Mesos from the Mesosphere repository.
# This script is not needed if using the latest version of Apache mesos
# which is available in the Mesosphere repository that puppet-mesos uses.
#
# List of all available Apache Mesos rpm packages available at:
#   http://open.mesosphere.com/downloads/mesos/
#

BASE_URL="http://downloads.mesosphere.io/master/centos"
OS_REL="7"
MESOS_VERSION="0.23.0-1.0.centos701406"

BASEDIR=/tmp

cd ${BASEDIR}
/usr/bin/curl -sSL -OJ ${BASE_URL}/${OS_REL}/mesos-${MESOS_VERSION}.x86_64.rpm

if [ -d "/dist/" ]; then
  mv -f ${BASEDIR}/mesos-*.rpm /dist/
fi
