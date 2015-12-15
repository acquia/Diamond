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
  $mesos_version = '0.23.0-1.0.centos701406',
  $mesos_base_dir = '/var',
  $mesos_dns = undef,
) {
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

  class { '::mesos':
    version        => $mesos_version,
    conf_dir       => '/etc/mesos',
    log_dir        => $mesos_log_dir,
    manage_zk_file => true,
    zookeeper      => $mesos_zookeeper_connection_string,
    master_port    => 5050,
    ulimit         => 8192,
  }

  if $mesos_master {
    class { 'acquia_mesos::master':
      mesos_log_dir => $mesos_log_dir,
      mesos_lib_dir => $mesos_lib_dir,
      mesos_dns     => $mesos_dns,
    }
    contain acquia_mesos::master
  } else {
    class { 'acquia_mesos::agent':
      mesos_lib_dir => $mesos_lib_dir,
      mesos_dns     => $mesos_dns,
    }
    contain acquia_mesos::agent

    if $logstream_name {
      contain acquia_mesos::services::logstream
    }
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
