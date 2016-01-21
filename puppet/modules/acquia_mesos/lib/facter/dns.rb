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
require 'time'

def parse_leases_file(file = '/var/lib/dhclient/dhclient.leases')
  return {} unless File.exist?(file)
  leases = []
  l = {}
  File.open(file).each_line { |line|
    case line
    when /^lease \{/
      l = {}
    when /fixed-address (.*);/
      l[:ip] = $1
    when /interface (.*);/
      l[:interface] = $1
    when /option domain-name (.*);/
      l[:domain_name] = $1
    when /option domain-name-servers (.*);/
      puts $1
      l[:domain_name_servers] = $1
    when /renew \d+ (.+);/
      l[:renew] = Time.parse $1
    when /^\}/
      leases << l.clone
    end
  }
  leases.sort_by { |lease| lease[:renew] }.last
end

if AwsHelper.server_type_is?('mesos')
  stack = AwsHelper.stack
  unless stack.nil?
    current_lease = parse_leases_file

    Facter.add(:dns_ec2_internal_domain_name) do
      setcode do
        current_lease[:domain_name] || 'ec2.internal'
      end
    end

    Facter.add(:dns_ec2_internal_domain_name_servers) do
      setcode do
        current_lease[:domain_name_servers]
      end
    end

  end
end
