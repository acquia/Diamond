#!/bin/bash

set -ex

: ${DOCKER_STORAGE_SETUP_VERSION:=master}
: ${PACKAGE_DIST_DIR:=/dist}

BASEDIR=/tmp
SOURCEDIR=${BASEDIR}/docker-storage-setup

git clone -b ${DOCKER_STORAGE_SETUP_VERSION} https://github.com/projectatomic/docker-storage-setup.git ${SOURCEDIR}
cd ${SOURCEDIR}
rpmbuild --define "_sourcedir ${SOURCEDIR}" -bb docker-storage-setup.spec

if [ -d "${PACKAGE_DIST_DIR}" ]; then
  mv -f ${HOME}/rpmbuild/RPMS/x86_64/docker-storage-setup-*.rpm ${PACKAGE_DIST_DIR}/
fi
