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

if AwsHelper.server_type_is?('mesos_master')
  stack = AwsHelper.stack
  unless stack.nil?
    Facter.add(:api_docker_env) do
      setcode do
        env = [
          "AWS_REGION=#{AwsHelper.region}"
        ]

        # Add logstream env options to grid-api so it can launch containers with correctly routed logs
        if Facter.value('logstream_name')
          logstream_env = [
            'AG_LOGSTREAM=1',
            'AG_LOGSTREAM_DRIVER=fluentd',
            'AG_LOGSTREAM_DRIVER_OPTS=fluentd-address=0.0.0.0:24224',
            'AG_LOGSTREAM_TAG_PREFIX=grid',
          ]
          env.concat(logstream_env)
        end

        # Add bugsnag key if one is available
        if Facter.value('bugsnag_key')
          env << "AG_BUGSNAG_KEY=#{Facter.value('bugsnag_key')}"
        end

        # Add grid-api RDS DSN if is provided
        if Facter.value('grid_api_rds_dsn')
          env << "AG_DATABASE_DSN=#{Facter.value('grid_api_rds_dsn')}"
        end

        # Configure properties required to provision ELBs
        if stack.resource('MesosAgentELBSecurityGroup')
          env << "AG_LOADBALANCER_ELB_SECURITY_GROUP=#{stack.resource('MesosAgentELBSecurityGroup').physical_resource_id}"
        end
        if stack.parameter('Subnets')
          env << "AG_LOADBALANCER_ELB_SUBNETS=#{stack.parameter('Subnets')}"
        end

        env
      end
    end
  end
end
