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

class acquia_mesos::services::ui(
  $version = 'standalone-0.1.2',
  $port = 5000,
){
  docker::image { 'capgemini/mesos-ui':
    image     => 'capgemini/mesos-ui',
    image_tag => "${version}",
    force     => true,
  }

  docker::run { 'mesos-ui':
    image            => "capgemini/mesos-ui:${version}",
    ports            => ["${port}:${port}"],
    expose           => ["${port}"],
    detach           => false,
    restart_service  => true,
    privileged       => false,
    env              => [
      "MESOS_ENDPOINT=http://${ec2_public_ipv4}:5050"
    ],
    extra_parameters => [
      '--restart=always',
    ],
    require          => [
      Docker::Image['acquia/grid-api'],
    ],
  }
}
