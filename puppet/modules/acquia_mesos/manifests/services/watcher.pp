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

class acquia_mesos::services::watcher(
  $version = 'latest',
  $watcher_host = '0.0.0.0',
  $watcher_port = 6677,
  $baragon_host = '0.0.0.0',
  $baragon_port = 6060,
){
  $env = [
    "ALB_HOST=${watcher_host}",
    "ALB_PORT=${watcher_port}",
    "ALB_ZK_SERVERS=${aurora_zookeeper_connection_string}",
    "ALB_BARAGON_API=http://${baragon_host}:${baragon_port}/baragon/v2"
  ]

  docker::image { 'acquia/grid-watcher':
    image     => "${private_docker_registry}acquia/grid-watcher",
    image_tag => "${version}",
    force     => true,
  }

  docker::run { 'grid-watcher':
    image            => "${private_docker_registry}acquia/grid-watcher:${version}",
    env              => $env,
    ports            => ["${watcher_port}"],
    expose           => ["${watcher_port}"],
    restart          => always,
    extra_parameters => [
      '--restart=always',
      '-d',
      '--log-driver=syslog --log-opt syslog-facility=daemon --log-opt tag="grid-watcher"'
    ],
    privileged       => false,
    require          => [
      Docker::Image['acquia/grid-watcher'],
    ],
  }
}
