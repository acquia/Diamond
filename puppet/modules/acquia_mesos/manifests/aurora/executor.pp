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

class acquia_mesos::aurora::executor(
  $version       = 'present',
  $observer_port = 1338,
) {
  $aurora_ensure = $version? {
    undef    => 'absent',
    default => $version,
  }

  package { 'aurora-executor':
    ensure  => $aurora_ensure,
  }

  file { '/etc/sysconfig/thermos':
    ensure  => present,
    content => template('acquia_mesos/aurora/thermos.erb'),
    mode    => '0644',
    require => Package['aurora-executor'],
  }

  service { 'thermos':
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [
      Package['aurora-executor'],
      File['/etc/sysconfig/thermos'],
    ],
    subscribe  => [
      File['/etc/sysconfig/thermos'],
    ],
  }
}
