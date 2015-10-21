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

class MesosFactFinder
  attr_reader :ec2, :cf, :stack, :stack_name, :params

  def initialize(ec2)
    @ec2 = ec2
    @cf = AWS::CloudFormation.new
    @stack = cf.stack_resource(Facter.value('ec2_instance_id'))
    @stack_name = stack.stack_name
    @params = stack.stack.parameters
  end

  def self.mesos_instance?(ec2)
    ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'mesos'
  end

  # Return a list of the instance objects which belong to the Mesos
  # master autoscaling group.
  def mesos_master_instances
    if params['MesosMasterStack']
      master_cluster = params['MesosMasterStack']
      masters_autoscaling_group_id = cf.stacks[master_cluster].resources['MesosMasterAutoScalingGroup'].physical_resource_id
    else
      masters_autoscaling_group_id = cf.stacks[stack_name].resources['MesosMasterAutoScalingGroup'].physical_resource_id
    end
    group = AWS::AutoScaling::Group.new(masters_autoscaling_group_id)
    group.auto_scaling_instances.map { |i| ec2.instances[i.id] }
  end
end

ec2 = AWS::EC2.new
if MesosFactFinder.mesos_instance?(ec2)
  ff = MesosFactFinder.new(ec2)

  # Return the name of the mesos cluster
  Facter.add(:mesos_cluster_name) do
    setcode do
      ff.params['MesosClusterName'] || ff.stack_name
    end
  end

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
      ff.mesos_master_instances.map(&:ip_address).join(',')
    end
  end

  # Returns a list of mesos master private ips
  Facter.add(:mesos_masters_private_ips) do
    setcode do
      ff.mesos_master_instances.map(&:private_ip_address).join(',')
    end
  end

  # Mesos Master quorum value
  Facter.add(:mesos_quorum) do
    setcode do
      ff.mesos_master_instances.count / 2 + 1
    end
  end

  # Return the list of zookeeper private ips
  zookeeper_stack_name = ff.stack.stack.parameters['ZookeeperStack']
  node_list = ''
  if zookeeper_stack_name
    if ff.cf.stacks[zookeeper_stack_name].resources.map(&:logical_resource_id).include?('ZookeeperAutoScalingGroup')
      zk_nodes = []
      zk_autoscaling_group = ff.cf.stacks[zookeeper_stack_name].resources['ZookeeperAutoScalingGroup'].physical_resource_id
      autoscaling_group = AWS::AutoScaling::Group.new(zk_autoscaling_group)
      autoscaling_group.auto_scaling_instances.each { |i| zk_nodes << ec2.instances[i.id].private_ip_address }
      node_list = zk_nodes.map { |x| "#{x}:2181" }.join(',')
    end
  end

  Facter.add(:mesos_zookeeper_connection_string) do
    setcode do
      "zk://#{node_list}/mesos"
    end
  end

  Facter.add(:aurora_zookeeper_connection_string) do
    setcode do
      node_list
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
