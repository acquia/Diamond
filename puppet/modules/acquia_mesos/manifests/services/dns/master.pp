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

class acquia_mesos::services::dns::master (
  $version = 'latest'
){
  file { '/etc/mesos-dns':
    ensure    => directory,
  }

  file { '/etc/mesos-dns/mesos-dns.json':
    ensure  => present,
    content => template('acquia_mesos/services/dns/mesos-dns.json.erb'),
    require => File['/etc/mesos-dns'],
    notify  => Docker::Run['mesos-dns'],
  }

  docker::image { 'acquia/mesos-dns':
    image     => "${private_docker_registry}acquia/mesos-dns",
    image_tag => "${version}",
    force     => true,
  }

  docker::run { 'mesos-dns':
    image            => "${private_docker_registry}acquia/mesos-dns:${version}",
    command          => '-config=/etc/mesos-dns.json -logtostderr=true -v 0',
    ports            => ['53:53', '8123:8123'],
    privileged       => false,
    restart_service  => true,
    extra_parameters => [
      '--restart=always',
      '--log-driver=syslog --log-opt syslog-facility=daemon --log-opt tag=mesos-dns'
    ],
    volumes          => ['/etc/mesos-dns:/etc/'],
    require          => [
      Docker::Image['acquia/mesos-dns'],
      File['/etc/mesos-dns/mesos-dns.json'],
    ],
  }
}
