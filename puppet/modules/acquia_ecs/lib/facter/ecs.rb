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

if AwsHelper.server_type_is?('ecs')
  stack = AwsHelper.stack

  # Return the name of the cluster
  Facter.add(:ecs_cluster_name) do
    setcode do
      stack.stack_name
    end
  end

  Facter.add('docker_registry_url') do
    setcode do
      stack.parameter('DockerRegistryURL')
    end
  end

  Facter.add('docker_registry_auth') do
    setcode do
      stack.parameter('DockerRegistryAuthToken')
    end
  end

  Facter.add('docker_registry_email') do
    setcode do
      stack.parameter('DockerRegistryEmail')
    end
  end

  Facter.add('docker_min_port') do
    setcode do
      stack.parameter('DockerMinPort')
    end
  end

  Facter.add('docker_max_port') do
    setcode do
      stack.parameter('DockerMaxPort')
    end
  end
end
