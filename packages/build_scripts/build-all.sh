#!/bin/bash
#
# Copyright 2014 Acquia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# Build all package scripts in the current directory. To build a single script
# run with the name of that script as the first argument
#
# Usage:
# 	build-all.sh
# 	build-all.sh -b cassandra.sh
#
set -e

START_TIME=$(date +%s%N)
OS=$(lsb_release -is)
BUILD_SCRIPT_DIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
RELEASE_DIR=/vagrant/dist

function docker_run() {
  SCRIPT=$1
  DEBUG=$2

  # Set STDIN open, pseudo-TTY
  params="-it"
  # Delete container on exit
  params+=" --rm"
  # Allow all ports
  params+=" -P"
  # Add the name as a tag
  params+=" --name $(basename ${SCRIPT} .sh)"
  # Add the shared volume as the dist dir
  params+=" -v ${RELEASE_DIR}:/dist -v ${BUILD_SCRIPT_DIR}:/build"
  # Add ssh forwarding
  params+=" -v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent"
  # Add the default docker image to run in
  params+=" nemesis"
  # If not in debug run the build script, otherwise drop into the shell
  if [[ "$DEBUG" == "0" ]]; then
    params+=" /bin/bash -C /build/${SCRIPT}"
  else
  	params+=" /bin/bash"
  fi

  docker run $params
}

regex="*.sh"
debug=0

usage() { echo "Usage: $0 [-b <regex>] [-d]" 1>&2; exit 1; }

while getopts "hdb:" o; do
  case "${o}" in
    d)
	  debug=1
      ;;
    b)
      regex=${OPTARG}
      ;;
    *)
      usage
      ;;
    esac
done
shift $((OPTIND-1))

if [ "$OS" != "Ubuntu" ]; then
  echo "Build scripts require an Ubuntu based distribution"
  exit 1
fi

mkdir -p ${RELEASE_DIR}

cd ${BUILD_SCRIPT_DIR}
for x in ${regex}; do
  if [[ -f ${x} && "${x}" != $(basename $0) ]]; then
    echo
    echo "Building ${x}"
    echo
    docker_run $x $debug
    echo
  fi
done

END_TIME=$(date +%s%N)
EXEC_TIME=$(echo "scale=5; (${END_TIME} - ${START_TIME}) / 1000000000" | bc)

# Remove any containers that have a status of 'Exited'
if [[ "$(docker ps -a | grep Exited | wc -l)" -gt "0" && "$DEBUG" != 1 ]]; then
  docker rm $(docker ps -a | grep Exited | awk '{print $1}')
fi

echo "completed in ${EXEC_TIME} seconds"
