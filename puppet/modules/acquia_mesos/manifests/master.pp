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

class acquia_mesos::master (
  $mesos_log_dir = '/var/log/mesos',
  $mesos_work_dir = '/var/lib/mesos',
  $api = undef,
  $watcher = undef,
  $baragon = undef,
  $dns = undef,
  $ui = undef,
) {
  if $api {
    class { 'acquia_mesos::services::api':
      version               => $api,
      remote_scheduler_host => $ec2_public_ipv4,
      baragon_version       => $baragon,
    }
  }

  if $watcher {
    class { 'acquia_mesos::services::watcher':
      version      => $watcher,
      watcher_host => $ec2_local_ipv4,
      baragon_host => $ec2_local_ipv4,
      baragon_port => 6060,
    }
  }

  if $baragon {
    class { 'acquia_mesos::services::baragon':
      version      => $baragon,
      baragon_host => $ec2_local_ipv4,
      baragon_port => 6060,
    }
  }

  if $dns {
    class { 'acquia_mesos::services::dns::master':
      version      => $dns,
    }
  }

  if $ui {
    class { 'acquia_mesos::services::ui':
      version      => $ui,
    }
  }

  class {'::mesos::master':
    enable         => true,
    cluster        => $mesos_cluster_name,
    work_dir       => $mesos_work_dir,
    zookeeper      => $mesos_zookeeper_connection_string,
    listen_address => $ec2_local_ipv4,
    options        => {
      'hostname'                 => $ec2_public_ipv4,
      # 'advertise_ip'             => $ec2_public_ipv4, # TODO: enable when running mesos 0.26
      'external_log_file'        => "${mesos_log_dir}/mesos-master.INFO",
      'log_auto_initialize'      => true,
      # 'max_executors_per_slave'  => '24', # TODO: enable when compiled --with-network-isolator
      'quorum'                   => "${mesos_quorum}",
      'registry'                 => 'replicated_log',
      'registry_store_timeout'   => '10secs',
      'root_submissions'         => true,
      'slave_removal_rate_limit' => '100/1mins',
    },
    force_provider => 'systemd',
  }

  class {'::mesos::slave':
    enable         => false,
  }
}
