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
  $baragon_port = 6060,
){

  file { '/etc/baragon':
    ensure  => directory,
  }

  file { '/etc/baragon/baragon.yaml':
    ensure  => present,
    content => template('acquia_mesos/baragon.yaml.erb'),
    require => File['/etc/baragon'],
  }

  docker::image { 'acquia/baragon-master':
    image     => "${private_docker_registry}acquia/baragon-master",
    image_tag => "${version}",
    force     => true,
  }

  docker::run { 'baragon-master':
    image            => "${private_docker_registry}acquia/baragon-master:${version}",
    ports            => ["${baragon_port}"],
    expose           => ["${baragon_port}"],
    env              => [
      "BARAGON_PORT=${baragon_port}",
      "BARAGON_HOSTNAME=${ec2_local_ipv4}",
    ],
    volumes          => ['/etc/baragon/baragon.yaml:/etc/baragon/baragon.yaml'],
    command          => "/usr/bin/java -Ddw.hostname=${ec2_local_ipv4} -Ddw.server.connector.port=${baragon_port} -jar /etc/baragon/baragon-master.jar server /etc/baragon/baragon.yaml",
    restart          => always,
    extra_parameters => [
      '--restart=always',
      '-d',
      '--log-driver=syslog --log-opt syslog-facility=daemon --log-opt tag="baragonservice-master"'
    ],
    privileged       => false,
    require          => [
      File['/etc/baragon/baragon.yaml'],
      Docker::Image['acquia/baragon-master'],
    ],
  }
}
