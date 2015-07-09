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

class acquia_mesos::aurora(
  $cluster_name = $::mesos_cluster_name,
  $zookeeper_servers = $::aurora_zookeeper_connection_string,
  $scheduler_zk_path = '/aurora/scheduler',
  $slave_root = '/mnt/lib/mesos',
  $slave_run_directory = 'latest',
  $auth_mechanism = 'UNAUTHENTICATED',
){

  file { '/etc/aurora':
    ensure => directory,
  }

  file { '/etc/aurora/clusters.json':
    ensure  => present,
    content => template('acquia_mesos/clusters.json.erb'),
    require => File['/etc/aurora'],
  }
}
