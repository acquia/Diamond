#!/bin/bash

set -ex

: ${DOCKER_STORAGE_SETUP_REPO:=projectatomic}
: ${DOCKER_STORAGE_SETUP_VERSION:=master}
: ${PACKAGE_DIST_DIR:=/dist}

BASEDIR=/tmp
SOURCEDIR=${BASEDIR}/docker-storage-setup
TOPDIR=${BASEDIR}/rpmbuild

mkdir -p ${TOPDIR}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

git clone -b ${DOCKER_STORAGE_SETUP_VERSION} https://github.com/${DOCKER_STORAGE_SETUP_REPO}/docker-storage-setup.git ${SOURCEDIR}
cd ${SOURCEDIR}
rpmbuild --define "_sourcedir ${SOURCEDIR}" --define "_topdir ${TOPDIR}" -bb docker-storage-setup.spec

if [ -d "${PACKAGE_DIST_DIR}" ]; then
  mv -f ${TOPDIR}/RPMS/x86_64/docker-storage-setup-*.rpm ${PACKAGE_DIST_DIR}/
fi