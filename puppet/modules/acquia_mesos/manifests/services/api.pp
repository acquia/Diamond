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

class acquia_mesos::services::api(
  $version = 'latest',
  $remote_scheduler_host = '0.0.0.0',
  $remote_scheduler_port = 8081,
  $api_port = 2114,
  $baragon_version = undef,
){
  $default_env = [
    "AG_REMOTE_SCHEDULER_HOST=${remote_scheduler_host}",
    "AG_REMOTE_SCHEDULER_PORT=${remote_scheduler_port}",
  ]

  if $baragon_version {
    $baragon_env = [
      'AG_LOADBALANCERS=1',
      "AG_LOADBALANCER_ZK_SERVERS=${aurora_zookeeper_connection_string}",
      "AG_LOADBALANCER_SOURCE=${private_docker_registry}acquia/baragon-agent:${baragon_version}"
    ]
  } else {
    $baragon_env = []
  }

  docker::image { 'acquia/grid-api':
    image     => "${private_docker_registry}acquia/grid-api",
    image_tag => "${version}",
    force     => true,
  }

  docker::run { 'grid-api':
    image            => "${private_docker_registry}acquia/grid-api:${version}",
    env              => concat($default_env, $baragon_env, $api_docker_env),
    ports            => ["${api_port}:${api_port}"],
    expose           => ["${api_port}"],
    restart          => always,
    extra_parameters => [
      '--restart=always',
      '-d',
      '--net=host',
      '--log-driver=syslog --log-opt syslog-facility=daemon --log-opt tag="grid-api"'
    ],
    privileged       => false,
    require          => [
      Docker::Image['acquia/grid-api'],
    ],
  }
}
