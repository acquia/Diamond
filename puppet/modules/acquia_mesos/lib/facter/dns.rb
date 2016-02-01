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
#
# Facts to lookup and provide the currnet internal AWS DHCP nameservers in use.
#
require 'facter'
require 'aws_helper'

if AwsHelper.server_type_is?('mesos_master') || AwsHelper.server_type_is?('mesos_agent')
  stack = AwsHelper.stack
  unless stack.nil?
    Facter.add(:dns_ec2_internal_domain_name) do
      setcode do
        'ec2.internal'
      end
    end

    Facter.add(:dns_ec2_internal_domain_name_servers) do
      setcode do
        mac_addr = Facter.value('ec2_mac')
        cidr_full = Facter.value("ec2_network_interfaces_macs_#{mac_addr}_vpc_ipv4_cidr_block")
        cidr_ip = cidr_full.split('/').first
        cidr_base = cidr_ip.rpartition('.').first
        last_octet = cidr_ip.rpartition('.').last
        dns_octet = last_octet.to_i + 2
        dns_ip = [cidr_base, dns_octet].join('.')
        dns_ip
      end
    end

  end
end
