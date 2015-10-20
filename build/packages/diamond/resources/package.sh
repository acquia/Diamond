#!/bin/bash

VERSION=3.1.1
BUILD_VERSION=acquia1

if [ -d "diamond" ]; then
  rm -rf diamond
fi

git clone https://github.com/acquia/Diamond.git diamond
cd diamond
dch -v ${VERSION}~${BUILD_VERSION} -u low --maintmaint "Acquia package builder <engineering@acquia.com> $(date -R)"
dpkg-buildpackage -b -d -tc -uc

if [ -d "/dist/" ]; then
  mv -f ../*.deb /dist/
fi
