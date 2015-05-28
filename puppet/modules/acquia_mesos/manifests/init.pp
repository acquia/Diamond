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

class acquia_mesos {

  $mesos_repo = 'mesosphere'
  $mesos_version = '0.22.0-1.0.ubuntu1404'

  file {'/var/lib/mesos':
    ensure  => 'link',
    force   => true,
    target  => '/mnt/lib/mesos',
    require => File['/mnt/lib/mesos'],
  }

  class{'::mesos':
    version        => $mesos_version,
    repo           => $mesos_repo,
    log_dir        => '/var/log/mesos',
    conf_dir       => '/etc/mesos',
    manage_zk_file => true,
    zookeeper      => $mesos_zookeeper_connection_string,
    ulimit         => '8192',
    use_syslog     => false,
  }

  if $mesos_master {
    class {'::mesos::master':
      enable         => true,
      work_dir       => '/mnt/lib/mesos',
      zookeeper      => $mesos_zookeeper_connection_string,
      listen_address => $ec2_local_ipv4,
      options        => {
        'quorum' => "${mesos_quorum}",
      },
      force_provider => 'upstart',
    }
  } else {
    class {'::mesos::slave':
      enable         => true,
      work_dir       => '/mnt/lib/mesos',
      zookeeper      => $mesos_zookeeper_connection_string,
      listen_address => $ec2_local_ipv4,
      options        => {
        'containerizers' => 'docker,mesos',
        'hostname'       => $hostname,
      },
      resources      => {
        'cpus'  => "${processorcount}",
        'mem'   => "${mesos_slave_memorysize_mb}",
        'disk'  => "${mesos_slave_disk_space}",
        'ports' => '[2000-65535]',
      },
      attributes     => {
        'host' => $hostname,
        'rack' => $ec2_placement_availability_zone,
      },
      force_provider => 'upstart',
    }
  }

  logrotate::rule { 'mesos_logrotate':
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