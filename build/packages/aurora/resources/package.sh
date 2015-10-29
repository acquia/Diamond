#!/bin/bash
set -ex

: ${AURORA_VERSION:=0.9.0}
: ${AURORA_GIT_TAG:=aurora-1095}
: ${AURORA_PACKAGING_GIT_TAG:=master}

BASEDIR=/tmp

mkdir -p ${BASEDIR}/aurora-packaging
curl -sSL https://github.com/apache/aurora-packaging/archive/${AURORA_PACKAGING_GIT_TAG}.tar.gz | tar -xz --strip 1 -C ${BASEDIR}/aurora-packaging

cp ${BASEDIR}/aurora-packaging/builder/rpm/centos-7/pants.ini /
ln -s ${BASEDIR}/aurora-packaging/specs /specs || true

mkdir -p ${BASEDIR}/apache-aurora-${AURORA_VERSION}
curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -sSL https://api.github.com/repos/acquia/aurora/tarball/${AURORA_GIT_TAG} | tar -xz --strip 1 -C ${BASEDIR}/apache-aurora-${AURORA_VERSION}

export TOPDIR=${BASEDIR}/apache-aurora-${AURORA_VERSION}
export DIST_DIR=$HOME
export AURORA_VERSION=${AURORA_VERSION}

cd ${BASEDIR} && tar -czf /src.tar.gz apache-aurora-${AURORA_VERSION}
cd ${BASEDIR}/aurora-packaging/specs/rpm
make srpm
yum-builddep -y ${DIST_DIR}/rpmbuild/SRPMS/*
make rpm

if [ -d "/dist/" ]; then
  mv -f $HOME/rpmbuild/RPMS/x86_64/*.rpm /dist/
fi
