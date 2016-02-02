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

class acquia_mesos::services::dns::agent {
  class { 'dnsmasq':
    exported => false,
  }

  dnsmasq::conf { 'mesos':
    ensure  => present,
    prio    => '10',
    content => template('acquia_mesos/services/dns/dnsmasq-10-mesos.erb'),
  }

  class { 'resolv_conf':
    nameservers => ['127.0.0.1', $dns_ec2_internal_domain_name_servers],
    searchpath  => ['mesos', $dns_ec2_internal_domain_name ],
    require     => [
      Dnsmasq::Conf['mesos'],
      Class['dnsmasq'],
    ],
  }
}