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

class acquia_mesos::aurora::scheduler(
  $version                 = 'present',
  $user                    = 'aurora',
  $group                   = 'aurora',

  # Scheduler Options
  $log_level               = 'INFO',
  $libmesos_log_verbosity  = 0,
  $libprocess_port         = '8083',
  $libprocess_ip           = '127.0.0.1',
  $java_opts               = [
                                # Uses server-level GC optimizations, as this is a server.
                                '-server',
                                # Location of libmesos-XXXX.so / libmesos-XXXX.dylib
                                "-Djava.library.path='/usr/lib;/usr/lib64'",
                              ],
  $cluster_name            = 'mesos',
  $http_port               = '8081',
  $quorum_size             = 1,
  $zookeeper               = '127.0.0.1:2181',
  $zookeeper_mesos_path    = 'mesos',
  $zookeeper_aurora_path   = 'aurora',
  $aurora_home             = '/var/lib/aurora',
  $thermos_executor_path   = '/usr/bin/thermos_executor',
  $thermos_executor_flags  = [
                                '--announcer-enable',
                                '--announcer-ensemble 127.0.0.1:2181',
                              ],
  $allowed_container_types = ['DOCKER','MESOS'],
  $extra_scheduler_args    = [],

  # Executor Options
  $auth_mechanism          = 'UNAUTHENTICATED',
  $executor_run_directory  = 'latest',
  $mesos_work_dir          = '/var/lib/mesos',
) {
  $aurora_ensure = $version? {
    undef   => 'absent',
    default => $version,
  }

  group { "${group}":
    ensure => present,
  }

  user { "${user}":
    ensure  => present,
    groups  => "${group}",
    home    => "${aurora_home}",
    shell   => '/bin/false',
    comment => 'Apache Aurora User',
    require => Group["${group}"],
  }

  package { 'aurora-scheduler':
    ensure => $aurora_ensure,
  }

  package { 'aurora-tools':
    ensure  => $aurora_ensure,
    require => Package['aurora-scheduler'],
  }

  file{ "${aurora_home}":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '0644',
  }

  file { "${aurora_home}/scheduler":
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => File["${aurora_home}"],
  }

  file { "${aurora_home}/scheduler/db":
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => [
      File["${aurora_home}/scheduler"],
    ]
  }

  file { '/etc/aurora':
    ensure => directory,
  }

  file { '/etc/aurora/clusters.json':
    ensure  => present,
    content => template('acquia_mesos/aurora/clusters.json.erb'),
    require => File['/etc/aurora'],
  }

  file { '/etc/sysconfig/aurora-scheduler':
    ensure  => present,
    content => template('acquia_mesos/aurora/aurora-scheduler.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => Package['aurora-scheduler'],
    notify  => Service['aurora-scheduler'],
  }

  exec { 'init-mesos-log':
    command => "/usr/bin/mesos-log initialize --path=${aurora_home}/scheduler/db",
    unless  => "/usr/bin/test -f ${aurora_home}/scheduler/db/CURRENT",
    require => [
      File["${aurora_home}"],
      File["${aurora_home}/scheduler"],
      File["${aurora_home}/scheduler/db"],
      Package['aurora-scheduler'],
    ],
    notify  => [
      Exec['set_aurora_home_perms'],
      Service['aurora-scheduler'],
    ],
  }

  exec { 'set_aurora_home_perms':
    command => "/usr/bin/chown -R ${user}:${group} ${aurora_home}",
    require => [
      File["${aurora_home}"],
      File["${aurora_home}/scheduler"],
      File["${aurora_home}/scheduler/db"],
      Exec['init-mesos-log'],
    ],
    notify  => Service['aurora-scheduler'],
  }

  service { 'aurora-scheduler':
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [
      Package['aurora-scheduler'],
      Package['aurora-tools'],
      File['/etc/sysconfig/aurora-scheduler'],
      Exec['init-mesos-log'],
    ],
    subscribe  => [
      File['/etc/sysconfig/aurora-scheduler'],
    ],
  }
}
