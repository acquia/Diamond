#!/usr/bin/env bash
set -ex

: ${BARAGON_GIT_TAG:=master}

export BARAGON_TMPDIR=/tmp

BUILDDIR=/tmp/baragon

mkdir -p ${BUILDDIR}
curl -sSL https://api.github.com/repos/acquia/baragon/tarball/${BARAGON_GIT_TAG} | tar -xz --strip 1 -C ${BUILDDIR}

cd ${BUILDDIR}
mvn package

if [ -d "/dist/" ]; then
  cp  BaragonService/target/BaragonService*-shaded.jar /dist/baragon-master.jar
  cp  BaragonAgentService/target/BaragonAgentService*-shaded.jar /dist/baragon-agent.jar
fi
