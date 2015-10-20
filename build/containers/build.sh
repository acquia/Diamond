#!/bin/bash

if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
 echo "Error: GITHUB_OAUTH_TOKEN environment variable not set"
 exit 1
fi

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

mkdir -p ${BASEDIR}/../dist

# Find any containers and build them
for f in $(find . -name Dockerfile -maxdepth 3); do
  f=${f#./}
  dir=$(dirname $f)

  name=$dir
  tag="latest"

  if [[ "${dir}" =~ "/" ]]; then
  	name=$(echo "${dir}" | cut -d "/" -f 1)
  	tag=$(echo "${dir}" | cut -d "/" -f 2)
  fi

  echo "building: ${name}:${tag}"
  docker build -t "${name}:${tag}" $dir
done

# Find any scripts and build them out as well
for f in $(find . -name build.sh -mindepth 2); do
  name=$(dirname $f)
  echo "building: ${name}"
  /bin/bash $f
done
