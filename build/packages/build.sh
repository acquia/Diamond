#!/bin/bash

if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
 echo "Error: GITHUB_OAUTH_TOKEN environment variable not set"
 exit 1
fi

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

mkdir -p ${BASEDIR}/../dist

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
  CONTAINER_ID=$(docker run -d -e "GITHUB_OAUTH_TOKEN=${GITHUB_OAUTH_TOKEN}" -v ${BASEDIR}/../dist:/dist "${name}:${tag}")
  docker wait ${CONTAINER_ID}
  docker rm ${CONTAINER_ID}
done