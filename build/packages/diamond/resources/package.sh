#!/bin/bash

set -ex

: ${DIAMOND_VERSION:=master}
: ${PACKAGE_DIST_DIR:=/dist}

BASEDIR=/tmp

cd ${BASEDIR}
git clone -b ${DIAMOND_VERSION} https://github.com/acquia/Diamond.git diamond
cd ${BASEDIR}/diamond
make rpm

if [ -d "${PACKAGE_DIST_DIR}" ]; then
  mv -f dist/diamond-*.noarch.rpm ${PACKAGE_DIST_DIR}/
fi
