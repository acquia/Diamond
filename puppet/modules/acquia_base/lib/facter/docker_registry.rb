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

stack = AwsHelper.stack
if stack
  if stack.parameter('DockerRegistry') == 'AWS'
    client = Aws::ECR::Client.new(region: AwsHelper.region)
    authorization_token = client.get_authorization_token
    data = authorization_token.authorization_data.first

    user, token = Base64.decode64(data.authorization_token).split(':')
    endpoint = data.proxy_endpoint.gsub!(%r{^https:\/\/}, '')

    Facter.add('docker_registry_endpoint') do
      setcode do
        endpoint
      end
    end

    Facter.add('docker_registry_username') do
      setcode do
        user
      end
    end

    Facter.add('docker_registry_password') do
      setcode do
        token
      end
    end
  end
end
