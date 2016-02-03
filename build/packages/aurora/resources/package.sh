#!/bin/bash
set -ex

: ${AURORA_VERSION:=0.10.0}
: ${AURORA_GIT_TAG:=acquia-0.10.0}
: ${AURORA_PACKAGING_GIT_REPO:=jfarrell}
: ${AURORA_PACKAGING_GIT_TAG:=0.10.x}
: ${PACKAGE_DIST_DIR:=/dist}

BASEDIR=/tmp

mkdir -p ${BASEDIR}/aurora-packaging
curl -sSL https://github.com/${AURORA_PACKAGING_GIT_REPO}/aurora-packaging/archive/${AURORA_PACKAGING_GIT_TAG}.tar.gz | tar -xz --strip 1 -C ${BASEDIR}/aurora-packaging

cp ${BASEDIR}/aurora-packaging/builder/rpm/centos-7/pants.ini /
ln -s ${BASEDIR}/aurora-packaging/specs /specs || true

# Clone the Aurora repo
mkdir -p ${BASEDIR}/apache-aurora-${AURORA_VERSION}
curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -sSL https://api.github.com/repos/acquia/aurora/tarball/${AURORA_GIT_TAG} | tar -xz --strip 1 -C ${BASEDIR}/apache-aurora-${AURORA_VERSION}

export TOPDIR=${BASEDIR}/apache-aurora-${AURORA_VERSION}
export DIST_DIR=${BASEDIR}
export AURORA_VERSION=${AURORA_VERSION}

cd ${BASEDIR} && tar -czf /src.tar.gz apache-aurora-${AURORA_VERSION}
cd ${BASEDIR}/aurora-packaging/specs/rpm
cp -a SOURCES/* ${HOME}/rpmbuild/SOURCES/
make srpm
yum clean all
yum-builddep -y ${DIST_DIR}/rpmbuild/SRPMS/*
make rpm

if [ -d "${PACKAGE_DIST_DIR}/" ]; then
  mv -f ${DIST_DIR}/rpmbuild/RPMS/x86_64/*.rpm ${PACKAGE_DIST_DIR}/
fi
