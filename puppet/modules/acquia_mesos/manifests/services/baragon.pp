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

class acquia_mesos::services::baragon(
  $version = 'latest',
  $baragon_host = $ec2_local_ipv4,
  $baragon_port = 6060,
){
  file { '/etc/baragon':
    ensure  => directory,
  }

  file { '/etc/baragon/baragon.yaml':
    ensure  => present,
    content => template('acquia_mesos/services/baragon.yaml.erb'),
    require => File['/etc/baragon'],
  }

  docker::image { 'acquia/baragon-master':
    image     => "${private_docker_registry}acquia/baragon-master",
    image_tag => "${version}",
    force     => true,
  }

  docker::run { 'baragon-master':
    image            => "${private_docker_registry}acquia/baragon-master:${version}",
    ports            => ["${baragon_port}:${baragon_port}"],
    expose           => ["${baragon_port}"],
    command          => "/usr/bin/java -Ddw.hostname=${baragon_host} -Ddw.server.connector.port=${baragon_port} -jar /etc/baragon/baragon-master.jar server /etc/baragon/baragon.yaml",
    detach           => false,
    restart_service  => true,
    privileged       => false,
    env              => [
      "BARAGON_PORT=${baragon_port}",
      "BARAGON_HOSTNAME=${baragon_host}",
    ],
    volumes          => [
      '/etc/baragon/baragon.yaml:/etc/baragon/baragon.yaml'
    ],
    extra_parameters => [
      '--restart=always',
      '--log-driver=syslog --log-opt syslog-facility=daemon --log-opt tag=baragonservice-master'
    ],
    require          => [
      File['/etc/baragon/baragon.yaml'],
      Docker::Image['acquia/baragon-master'],
    ],
  }
}
