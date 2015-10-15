#!/usr/bin/env bash
set -ex

export BARAGON_TMPDIR=/tmp

mkdir baragon
curl -sSL https://api.github.com/repos/hubspot/baragon/tarball/${GIT_TAG} | tar -xz --strip 1 -C baragon

cd baragon

# Try a few times because npm is flakey
n=0
until [ $n -ge 5 ]
do
  mvn package && break
  n=$[$n+1]
  sleep 5
done

if [ -d "/dist/" ]; then
  cp  BaragonService/target/BaragonService*-shaded.jar /dist/BaragonService.jar
  cp  BaragonAgentService/target/BaragonAgentService*-shaded.jar /dist/BaragonAgentService.jar
fi
