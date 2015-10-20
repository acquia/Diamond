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
  $mesos_base_dir = '/var'
) {
  include apt

  $mesos_log_dir = "${mesos_base_dir}/log/mesos"
  $mesos_lib_dir = "${mesos_base_dir}/lib/mesos"

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

  class { '::mesos':
    version        => $mesos_version,
    conf_dir       => '/etc/mesos',
    log_dir        => $mesos_log_dir,
    manage_zk_file => true,
    zookeeper      => $mesos_zookeeper_connection_string,
    master_port    => 5050,
    ulimit         => 8192,
    require        => Apt::Source['mesosphere'],
  }

  # TODO this needs to be removed once https://github.com/mesosphere/mesos-deb-packaging/pull/48
  # is merged or we switch to building Mesos ourselves
  package { 'libcurl4-nss-dev':
    ensure => latest,
  }

  # NOTE: This is a giant hack around the Apt and Mesos classes not playing
  # well together. Apt::Source should force the Mesos package install to wait
  # on apt-get update. This doesn't seem to be the case in 2.1.0 of the Apt
  # module
  Class['apt::update'] -> Class['mesos::install']

  if $mesos_master {
    class { 'acquia_mesos::master':
      mesos_log_dir => $mesos_log_dir,
      mesos_lib_dir => $mesos_lib_dir,
    }
    contain acquia_mesos::master
  } else {
    class { 'acquia_mesos::agent':
      mesos_lib_dir => $mesos_lib_dir
    }
    contain acquia_mesos::agent
  }

  logrotate::rule { 'mesos':
    path          => "${mesos_log_dir}/*.log",
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
