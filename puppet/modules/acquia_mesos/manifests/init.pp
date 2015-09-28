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

class acquia_mesos (
  $mesos_repo = 'mesosphere',
  $mesos_version = '0.23.0-1.0.ubuntu1404',
) {
  include apt

  file {'/var/lib/mesos':
    ensure  => 'link',
    force   => true,
    target  => '/mnt/lib/mesos',
    require => File['/mnt/lib/mesos'],
  }

  ensure_resource('file', '/mnt/tmp',
    {
      'ensure' => 'directory',
      'mode'   => '0755',
    }
  )

  file {'/mnt/tmp/mesos':
    ensure  => 'directory',
    mode    => '0755',
    require => File['/mnt/tmp'],
  }

  $distro = downcase($::operatingsystem)
  apt::source { 'mesosphere':
    location => "http://repos.mesosphere.io/${distro}",
    release  => $::lsbdistcodename,
    repos    => 'main',
    key      => '81026D0004C44CF7EF55ADF8DF7D54CBE56151BF',
  }

  class{'::mesos':
    version        => $mesos_version,
    conf_dir       => '/etc/mesos',
    log_dir        => '/var/log/mesos',
    manage_zk_file => true,
    zookeeper      => $mesos_zookeeper_connection_string,
    master_port    => 5050,
    ulimit         => 8192,
    use_syslog     => false,
    require        => Apt::Source['mesosphere'],
  }

  # NOTE: This is a giant hack around the Apt and Mesos classes not playing
  # well together. Apt::Source should force the Mesos package install to wait
  # on apt-get update. This doesn't seem to be the case in 2.1.0 of the Apt
  # module
  Class['apt::update'] -> Class['mesos::install']

  if $mesos_master {
    contain acquia_mesos::master
  } else {
    contain acquia_mesos::slave
  }

  logrotate::rule { 'mesos':
    path          => '/var/log/mesos/*.log',
    rotate        => 7,
    rotate_every  => 'day',
    size          => '250M',
    compress      => true,
    delaycompress => true,
    dateext       => true,
    missingok     => true,
    ifempty       => false,
    create        => true,
    create_mode   => '0644',
    create_owner  => 'root',
    create_group  => 'root',
  }
}
