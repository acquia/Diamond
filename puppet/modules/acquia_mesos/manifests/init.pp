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
  $aurora_version = '0.10.0-1.el7.centos.aurora',
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

  class { 'aurora':
    version           => $aurora_version,
    configure_repo    => false,
    master            => $mesos_master,
    scheduler_options => {
      'cluster_name'            => "${mesos_cluster_name}",
      'quorum_size'             => "${mesos_quorum}",
      'zookeeper'               => "${aurora_zookeeper_connection_string}",
      'thermos_executor_flags'  => [
        '--announcer-enable',
        "--announcer-ensemble ${aurora_zookeeper_connection_string}",
        '--log_to_std',
        '--preserve_env',
      ],
      'extra_scheduler_args'    => [
        '-allow_docker_parameters=true',
      ],
      # @todo: fix puppet-aurora params to use defaults for scheduler options. copied over for now.
      'log_level'               => 'INFO',
      'libmesos_log_verbosity'  => 0,
      'libprocess_port'         => '8083',
      'libprocess_ip'           => "${ec2_local_ipv4}",
      'java_opts'               => [
                                      '-server',
                                      "-Djava.library.path='/usr/lib;/usr/lib64'",
                                    ],
      'http_port'               => '8081',
      'zookeeper_mesos_path'    => 'mesos',
      'zookeeper_aurora_path'   => 'aurora',
      'aurora_home'             => '/var/lib/aurora',
      'thermos_executor_path'   => '/usr/bin/thermos_executor',
      'allowed_container_types' => ['DOCKER','MESOS'],
    },
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
