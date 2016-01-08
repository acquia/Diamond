#!/bin/bash

# Download a specific version of Apahce Mesos from the Mesosphere repository.
# This script is not needed if using the latest version of Apache mesos
# which is available in the Mesosphere repository that puppet-mesos uses.
#
# List of all available Apache Mesos rpm packages available at:
#   http://open.mesosphere.com/downloads/mesos/
#

: ${MESOS_VERSION:=0.23.0}
: ${MESOS_RPM_BUILD:=1.0.centos701406}
: ${PACKAGE_DIST_DIR:=/dist}

BASE_URL="http://downloads.mesosphere.io/master/centos"
OS_REL="7"
ARCH="x86_64"

RPM_NAME="mesos-${MESOS_VERSION}-${MESOS_RPM_BUILD}.${ARCH}.rpm"
BASEDIR=/tmp

cd ${BASEDIR}
/usr/bin/curl -sSL -OJ ${BASE_URL}/${OS_REL}/${RPM_NAME}

if [ -d "${PACKAGE_DIST_DIR}" ]; then
  mv -f ${BASEDIR}/${RPM_NAME} ${PACKAGE_DIST_DIR}/
fi
