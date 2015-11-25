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

class acquia_mesos::master_api {
  docker::image { 'acquia/grid-api':
    image     => 'acquia/grid-api',
    image_tag => 'latest',
    force     => true,
  }

  docker::run { 'grid-api':
    image            => 'acquia/grid-api',
    env              => [
      "AG_REMOTE_SCHEDULER_HOST=${ec2_public_ipv4}",
      'AG_REMOTE_SCHEDULER_PORT=8081',
    ],
    ports            => ['2114'],
    expose           => ['2114'],
    restart          => always,
    extra_parameters => ['--restart=always', '-d'],
    privileged       => false,
    require          => [
      Docker::Image['acquia/grid-api'],
    ],
  }
}
