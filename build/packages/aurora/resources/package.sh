#!/bin/bash
set -ex

: ${AURORA_GIT_TAG:=aurora-1095}
: ${AURORA_PACKAGING_GIT_TAG:=master}

if [ -d "aurora-packaging" ]; then
  rm -rf aurora-packaging
fi

mkdir -p aurora-packaging
curl -sSL https://github.com/apache/aurora-packaging/archive/${AURORA_PACKAGING_GIT_TAG}.tar.gz | tar -xz --strip 1 -C aurora-packaging

cp aurora-packaging/builder/deb/ubuntu-trusty/pants.ini /

if [ ! -d "aurora" ]; then
  if [ -z $GITHUB_OAUTH_TOKEN ]; then
    git clone -b ${AURORA_GIT_TAG} git@github.com:acquia/aurora.git
  else
    mkdir -p aurora
    curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -sSL https://api.github.com/repos/acquia/aurora/tarball/${AURORA_GIT_TAG} | tar -xz --strip 1 -C aurora
  fi
fi

cd aurora
ln -s ../aurora-packaging/specs/debian debian
dpkg-buildpackage -uc -b -tc

if [ -d "/dist/" ]; then
  mv -f ../*.deb /dist/
fi
