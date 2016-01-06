#!/bin/bash

: ${PACKAGE_DIST_DIR:=/dist}

BASEDIR=/tmp

rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
yum clean expire-cache
yum install -y --downloadonly --downloaddir=${BASEDIR}/puppet/ puppet

if [ -d "${PACKAGE_DIST_DIR}" ]; then
  mv -f ${BASEDIR}/puppet/*.rpm ${PACKAGE_DIST_DIR}/
fi
