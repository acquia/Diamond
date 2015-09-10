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

class acquia_ecs {
  file {'/var/lib/ecs':
    ensure  => 'directory',
  }

  file {'/var/lib/ecs/data':
    ensure  => 'directory',
    require => File['/var/lib/ecs'],
  }

  file {'/var/log/ecs':
    ensure  => 'directory',
  }

  file { '/etc/ecs/ecs.config':
    ensure  => present,
    content => template('acquia_ecs/ecs.config.erb'),
  }

  sysctl { 'net.ipv4.ip_local_port_range':
    ensure => 'present',
    value  => "${docker_min_port} ${docker_max_port}",
  }

  docker::image { 'amazon/amazon-ecs-agent':
    image_tag => 'latest',
  }

  docker::run { 'ecs-agent':
    image            => 'amazon/amazon-ecs-agent:latest',
    use_name         => true,
    volumes          => [
      '/var/run/docker.sock:/var/run/docker.sock',
      '/var/log/ecs:/log',
      '/var/lib/ecs/data:/data',
    ],
    env_file         => '/etc/ecs/ecs.config',
    ports            => ['51678'],
    expose           => ['51678'],
    restart          => always,
    extra_parameters => ['--restart=always', '-d'],
    privileged       => true,
    require          => [
      File['/etc/ecs/ecs.config'],
      Sysctl['net.ipv4.ip_local_port_range'],
      Docker::Image['amazon/amazon-ecs-agent'],
    ],
  }
}
