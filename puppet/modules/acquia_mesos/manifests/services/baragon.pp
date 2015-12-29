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
  $version = 'latest'
){

  file { '/etc/baragon':
    ensure  => directory,
  }

  file { '/etc/baragon/baragon_service_config.yaml':
    ensure  => present,
    content => template('acquia_mesos/baragon_service_config.yaml.erb'),
    require => File['/etc/baragon'],
  }

  docker::image { 'acquia/baragon-master':
    image     => "${private_docker_registry}acquia/baragon-master",
    image_tag => "${version}",
    force     => true,
  }

  docker::run { 'baragon-master':
    image            => "${private_docker_registry}acquia/baragon-master:${version}",
    ports            => ['0.0.0.0:8080:8080'],
    volumes          => ['/etc/baragon/baragon_service_config.yaml:/etc/baragon/baragon_service_config.yaml'],
    command          => 'java -jar /etc/baragon/BaragonService.jar server /etc/baragon/baragon_service_config.yaml',
    restart          => always,
    extra_parameters => [
      '--restart=always',
      '-d',
      '--log-driver=syslog --log-opt syslog-facility=daemon --log-opt tag="baragonservice-master"'
    ],
    privileged       => false,
    require          => [
      File['/etc/baragon/baragon_service_config.yaml'],
      Docker::Image['acquia/baragon-master'],
    ],
  }
}
