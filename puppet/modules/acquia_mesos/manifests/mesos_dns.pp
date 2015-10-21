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

class acquia_mesos::mesos_dns(
  $mesos_dns_version = 'latest',
) {
  file { '/etc/mesos-dns':
    ensure    => directory,
  }

  file { '/etc/mesos-dns/mesos-dns.json':
    ensure  => present,
    content => template('acquia_mesos/mesos-dns.json.erb'),
    require => File['/etc/mesos-dns'],
    notify  => Docker::Run['mesos-dns'],
  }

  if $registry_endpoint {
    $registry_prefix = "${registry_endpoint}/"
    } else {
    $registry_prefix = ''
  }
  docker::run { 'mesos-dns':
    image            => "${registry_prefix}acquia/mesos-dns:${mesos_dns_version}",
    command          => '-config=/etc/mesos-dns.json -logtostderr=true -v 0',
    use_name         => true,
    volumes          => ['/etc/mesos-dns:/etc'],
    ports            => ['0.0.0.0:53:53', '0.0.0.0:8123:8123'],
    extra_parameters => ['--restart=always', '-d', '--net=host'],
    privileged       => false,
    restart_service  => true,
    pull_on_start    => true,
    require          => [ File['/etc/mesos-dns/mesos-dns.json'], ],
  }
}
