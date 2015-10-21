#!/bin/bash
set -e

# Attempt to read the Github OAuth token from the global .gitconfig
GITHUB_OAUTH_TOKEN=$(git config --global github.token) || true

if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
 echo "Error: GITHUB_OAUTH_TOKEN environment variable not set"
 exit 1
else
  export GITHUB_OAUTH_TOKEN="${GITHUB_OAUTH_TOKEN}"
fi

BASEDIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

mkdir -p ${BASEDIR}/../dist

# Find any containers and build them
for f in $(find . -name Dockerfile -maxdepth 3); do
  f=${f#./}
  dir=$(dirname $f)

  name=$dir
  tag="latest"

  echo "building: ${name}:${tag}"
  docker build -t "${name}:${tag}" $dir
done

# Find any scripts and build them out as well
for f in $(find . -name build.sh -mindepth 2); do
  name=$(dirname $f)
  echo "building: ${name}"
  /bin/bash $f
done
