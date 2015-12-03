#!/bin/bash

set -ex

: ${DIAMOND_VERSION:=v4.0}

BASEDIR=/tmp

cd ${BASEDIR}
git clone -b ${DIAMOND_VERSION} https://github.com/acquia/Diamond.git diamond
cd ${BASEDIR}/diamond
make rpm

if [ -d "/dist/" ]; then
  mv -f dist/diamond-*.noarch.rpm /dist/
fi
