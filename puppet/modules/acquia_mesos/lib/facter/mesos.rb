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
require 'aws_helper'

# Provides methods for retrieving and interpreting information from
# Nemesis CloudFormation stacks.
module NemesisHelper
  class AutoScalingGroup
    attr_reader :stack_name

    class << self
      attr_reader :group_logical_id

      def set_group_logical_id(id)
        @group_logical_id = id
      end
    end

    def initialize(stack_name)
      @stack_name = stack_name
    end

    def autoscaling_group
      if @asg.nil?
        return nil unless stack_name
        stack = AwsHelper::CloudFormation.stack(stack_name)
        asg_resource = stack.resource_summaries.find { |s| s.logical_resource_id == self.class.group_logical_id }
        return nil unless asg_resource
        @asg = AwsHelper::AutoScaling.group_for_name(asg_resource.physical_resource_id)
      end
      @asg
    end

    def instances
      if @instances.nil?
        return [] if autoscaling_group.nil?
        @instances = AwsHelper::EC2.instances(autoscaling_group.instances.map(&:instance_id))
      end
      @instances
    end
  end

  class ZookeeperGroup < AutoScalingGroup
    set_group_logical_id 'ZookeeperAutoScalingGroup'

    def aurora_connection_string
      instances.map { |n| "#{n.private_ip_address}:2181" }.join(',')
    end
  end

  class MesosMasterGroup < AutoScalingGroup
    set_group_logical_id 'MesosMasterAutoScalingGroup'
  end
end

if AwsHelper.server_type_is?('mesos_master') || AwsHelper.server_type_is?('mesos_agent')
  stack = AwsHelper.stack
  unless stack.nil?
    # Return the name of the mesos cluster
    Facter.add(:mesos_cluster_name) do
      setcode do
        stack.parameter('MesosClusterName') || stack.stack_name
      end
    end

    # Fact to check and see if this node is a Mesos master or not
    Facter.add(:mesos_master) do
      setcode do
        AwsHelper.server_type_is?('mesos_master')
      end
    end

    mesos_masters = NemesisHelper::MesosMasterGroup.new(stack.parameter('MesosMasterStack') || stack.stack_name)

    # Returns a list of mesos masters
    Facter.add(:mesos_masters) do
      setcode do
        mesos_masters.instances.map(&:public_ip_address).join(',')
      end
    end

    # Returns a list of mesos master private ips
    Facter.add(:mesos_masters_private_ips) do
      setcode do
        mesos_masters.instances.map(&:private_ip_address).join(',')
      end
    end

    # Mesos Master quorum value
    Facter.add(:mesos_quorum) do
      setcode do
        mesos_masters.instances.count / 2 + 1
      end
    end

    zookeepers = NemesisHelper::ZookeeperGroup.new(stack.parameter('ZookeeperStack'))

    Facter.add(:mesos_zookeeper_connection_string) do
      setcode do
        "zk://#{zookeepers.aurora_connection_string}/mesos"
      end
    end

    Facter.add(:aurora_zookeeper_connection_string) do
      setcode do
        zookeepers.aurora_connection_string
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

  # Check if stack was launched with reference to kinesis log stream
  logstream_stack_name = stack.parameter('LogStreamStack')
  if logstream_stack_name
    Facter.add(:logstream_name) do
      setcode do
        AwsHelper::CloudFormation.stack(logstream_stack_name).output('NemesisKinesisStreamName')
      end
    end
  end

  # Check if stack was launched with reference to grid-api RDS
  # If yes create DSN (Data Source Name) string that allows grid-api MySQL driver
  # to connect to DB.
  grid_api_rds_stack_name = stack.parameter('GridApiRDSStack')
  if grid_api_rds_stack_name
    Facter.add(:grid_api_rds_dsn) do
      setcode do
        rds_stack = AwsHelper::CloudFormation.stack(grid_api_rds_stack_name)
        rds_username = rds_stack.parameter('DBMasterUsername')
        rds_password = rds_stack.parameter('DBMasterPassword')
        rds_host = rds_stack.output('RDSDnsName')
        rds_dbname = rds_stack.parameter('DBName')
        # DSN constructed by https://github.com/go-sql-driver/mysql#examples
        "#{rds_username}:#{rds_password}@tcp(#{rds_host}:3306)/#{rds_dbname}"
      end
    end
  end
end
