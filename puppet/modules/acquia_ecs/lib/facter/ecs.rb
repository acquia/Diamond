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
if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'ecs'

  cf = AWS::CloudFormation.new
  stack = cf.stack_resource(Facter.value('ec2_instance_id'))
  stack_name = stack.stack_name
  params = stack.stack.parameters

  # Return the name of the cluster
  Facter.add(:ecs_cluster_name) do
    setcode do
      stack_name
    end
  end

  Facter.add('docker_registry_url') do
    setcode do
      params['DockerRegistryURL']
    end
  end

  Facter.add('docker_registry_auth') do
    setcode do
      params['DockerRegistryAuthToken']
    end
  end

  Facter.add('docker_registry_email') do
    setcode do
      params['DockerRegistryEmail']
    end
  end

  Facter.add('docker_min_port') do
    setcode do
      params['DockerMinPort']
    end
  end

  Facter.add('docker_max_port') do
    setcode do
      params['DockerMaxPort']
    end
  end

end
