#!/usr/bin/env bash
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
# Download the latest version of Sumologic
#
set -ex

NAME="sumocollector"

BASEDIR=/tmp/${NAME}
rm -rf ${BASEDIR}
mkdir -p ${BASEDIR}


cd ${BASEDIR}
curl -sSL -OJ https://collectors.sumologic.com/rest/download/deb/64

# If we're in a VM, let's copy the deb file over
if [ -d "/dist/" ]; then
  mv -f ${BASEDIR}/${NAME}* /dist/
fi

rm -rf ${BASEDIR}