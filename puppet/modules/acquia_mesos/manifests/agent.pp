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

class acquia_mesos::agent(
  $mesos_work_dir = '/var/lib/mesos',
) {
  if $logstream_name {
    contain acquia_mesos::services::logstream
  }

  contain acquia_mesos::services::dns::agent

  class {'::mesos::slave':
    enable         => true,
    port           => 5051,
    work_dir       => $mesos_work_dir,
    zookeeper      => $mesos_zookeeper_connection_string,
    listen_address => $ec2_local_ipv4,
    options        => {
      'containerizers'                => 'docker,mesos',
      'docker_sandbox_directory'      => '/mnt/mesos/sandbox', # @todo: on mesos upgrade switch to new Mesos flag sandbox_directory
      # 'egress_rate_limit_per_container' => '37500KB', # @todo: enable when compiled --with-network-isolator
      'enforce_container_disk_quota'  => true,
      # 'ephemeral_ports_per_container'   => '1024', # @todo: enable when compiled --with-network-isolator
      'executor_registration_timeout' => '5mins',
      'hostname'                      => $ec2_local_ipv4,
      'perf_events'                   => 'cycles,instructions,task-clock,context-switches,cpu-migrations,stalled-cycles-frontend,stalled-cycles-backend,page-faults,L1-dcache-loads,L1-dcache-load-misses,L1-dcache-stores,L1-dcache-store-misses,LLC-loads,LLC-load-misses,LLC-stores,LLC-store-misses',
      'registration_backoff_factor'   => '10secs',
      'slave_subsystems'              => 'memory,cpuacct',
      'strict'                        => false,
    },
    resources      => {
      'cpus'            => "${mesos_slave_processorcount}",
      'mem'             => "${mesos_slave_memorysize_mb}",
      'disk'            => "${mesos_slave_disk_space}",
      'ports'           => '[31000-32000]',
      'ephemeral_ports' => '[32768-57344]',
    },
    attributes     => {
      'host' => $ec2_local_ipv4,
      'rack' => $ec2_placement_availability_zone,
    },
  }

  class {'::mesos::master':
    enable         => false,
  }
}
