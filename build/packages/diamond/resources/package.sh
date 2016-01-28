#!/bin/bash

set -ex

: ${DIAMOND_VERSION:=acquia}
: ${DIAMOND_PIN:=8cf5fc65176ccd8308b14ff613a6168d8092e497}
: ${PACKAGE_DIST_DIR:=/dist}

BASEDIR=/tmp

cd ${BASEDIR}
git clone -b ${DIAMOND_VERSION} https://github.com/acquia/Diamond.git diamond
cd ${BASEDIR}/diamond
git reset --hard ${DIAMOND_PIN}
make rpm

if [ -d "${PACKAGE_DIST_DIR}" ]; then
  mv -f dist/diamond-*.noarch.rpm ${PACKAGE_DIST_DIR}/
fi
