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

class acquia_mesos::services::logstream(
  $fluentd_version = 'latest',
  $docker_command = $docker::params::docker_command,
) {
  file { '/etc/fluentd/logstream':
    ensure    => directory,
  }

  file { '/etc/fluentd/logstream/td-agent.conf':
    ensure  => present,
    content => template('acquia_mesos/fluentd.conf.erb'),
    require => File['/etc/fluentd/logstream'],
    notify  => Exec['fluentd-config-reload'],
  }

  file { '/mnt/log/logstream':
    ensure  => directory,
  }

  # TODO(mhrabovcin): Do we need some cgroups limits on this container in terms of resource usage? This is running out of
  #                   mesos/aurora eye and its taking instance resources
  docker::run { 'logstream':
    image            => "${private_docker_registry}acquia/fluentd:${fluentd_version}",
    volumes          => [
      '/etc/fluentd/logstream:/etc/td-agent',
      # Used to store failed log messages and out_file plugin. @see fluentd.conf.erb
      '/mnt/log/logstream:/var/log/fluent/'
    ],
    ports            => ['24224'],
    extra_parameters => [
      '--restart=always',
      '-d',
      '--net=host',
      # Manually setting ulimit @see http://docs.fluentd.org/articles/before-install
      '--ulimit nofile=65536:65536',
      # Logging is set to syslog host instance to not have to deal with json and logrotation
      '--log-driver=syslog --log-opt syslog-facility=daemon --log-opt tag="logstream"'
    ],
    privileged       => false,
    restart_service  => true,
    pull_on_start    => true,
    require          => [
      File['/etc/fluentd/logstream/td-agent.conf'],
      File['/mnt/log/logstream'],
    ],
  }

  # Add exec command to send signal to running docker container
  # @see http://docs.fluentd.org/articles/signals
  validate_string($docker_command)
  exec { 'fluentd-config-reload':
    command     => "${docker_command} kill -s HUP logstream",
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
    refreshonly => true,
  }
}
