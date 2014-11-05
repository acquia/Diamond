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
# Build all package scripts in the current directory
#
set -e

START_TIME=$(date +%s%N)
OS=$(lsb_release -is)
BUILD_SCRIPT_DIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

if [ "$OS" != "Ubuntu" ]; then
  echo "Build scripts require an Ubuntu based distribution"
  exit 1
fi

cd ${BUILD_SCRIPT_DIR}
for x in *.sh; do
  if [[ "${x}" != $(basename $0) ]]; then
    echo
    echo "Building ${x}"
    echo
    /bin/bash ${x}
    echo
  fi
done

END_TIME=$(date +%s%N)
EXEC_TIME=$(echo "scale=5; (${END_TIME} - ${START_TIME}) / 1000000000" | bc)

echo "completed in ${EXEC_TIME} seconds"
