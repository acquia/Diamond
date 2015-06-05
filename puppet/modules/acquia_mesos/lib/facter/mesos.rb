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

require 'facter'
require 'aws-sdk'

ec2 = AWS::EC2.new
if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'mesos'

  cf = AWS::CloudFormation.new
  stack = cf.stack_resource(Facter.value('ec2_instance_id'))
  stack_name = stack.stack_name

  # Fact to check and see if this node is a Mesos master or not
  Facter.add(:mesos_master) do
    setcode do
      tags = ec2.instances[Facter.value('ec2_instance_id')].tags.to_h
      tags['master'] == 'true'
    end
  end

  # Returns a list of mesos masters
  Facter.add(:mesos_masters) do
    setcode do
      masters = []
      masters_autoscaling_group_id = cf.stacks[stack_name].resources['MesosMasterAutoScalingGroup'].physical_resource_id
      autoscaling_group = AWS::AutoScaling::Group.new(masters_autoscaling_group_id)
      autoscaling_group.auto_scaling_instances.each { |i| masters << ec2.instances[i.id].ip_address }
      masters.join(',')
    end
  end

  # Mesos Master quorum value
  Facter.add(:mesos_quorum) do
    setcode do
      masters_autoscaling_group_id = cf.stacks[stack_name].resources['MesosMasterAutoScalingGroup'].physical_resource_id
      autoscaling_group = AWS::AutoScaling::Group.new(masters_autoscaling_group_id)
      count = autoscaling_group.auto_scaling_instances.count
      count / 2 + 1
    end
  end

  # Return the list of zookeeper private ips
  Facter.add(:mesos_zookeeper_connection_string) do
    zookeeper_stack_name = stack.stack.parameters['ZookeeperStack']
    if zookeeper_stack_name
      if cf.stacks[zookeeper_stack_name].resources.map(&:logical_resource_id).include?('ZookeeperAutoScalingGroup')
        setcode do
          zk_nodes = []
          zk_autoscaling_group = cf.stacks[zookeeper_stack_name].resources['ZookeeperAutoScalingGroup'].physical_resource_id
          autoscaling_group = AWS::AutoScaling::Group.new(zk_autoscaling_group)
          autoscaling_group.auto_scaling_instances.each { |i| zk_nodes << ec2.instances[i.id].private_ip_address }
          node_list = zk_nodes.map { |x| "#{x}:2181" }.join(',')
          "zk://#{node_list}/mesos"
        end
      end
    end
  end

  # Report back AWS mount available disk space.
  Facter.add(:mesos_slave_disk_space) do
    setcode do
      # Checks to see if blockdevice_xvdb custom facts are available, otherwise it must not be mounted so use xvda
      if Facter.value('blockdevice_xvdb_size')
        Facter.value('blockdevice_xvdb_size').to_i / 1000000
      else
        Facter.value('blockdevice_xvda_size').to_i / 1000000
      end
    end
  end

  # Return the available memory size for this slave
  Facter.add(:mesos_slave_memorysize_mb) do
    setcode do
      Facter.value('memorysize_mb').to_i
    end
  end

  # Return the number of available cpu's
  Facter.add(:mesos_slave_processorcount) do
    setcode do
      Facter.value('processorcount').to_i
    end
  end
end
