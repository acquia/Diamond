#!/usr/bin/env bash

# Copyright 2015 Acquia, Inc.
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
# Builds a Docker image containing fluentd logging daemon that runs on agents

set -ex

# Get the directory where this script is located;
# WARNING this will fail if you run this script from a symlink
CURDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

: ${FLUENTD_TAG:="acquia/fluentd"}

# Create the builder container
docker build --no-cache -t ${FLUENTD_TAG} -f ${CURDIR}/Dockerfile .
