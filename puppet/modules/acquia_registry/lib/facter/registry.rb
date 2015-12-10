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

if stack.parameter('RegistryStack') || AwsHelper.server_type_is?('docker-registry')
  registry_stack = AwsHelper::CloudFormation.stack(stack.parameter('RegistryStack')) || stack

  registry_certificates_bucket = ::Aws::S3::Resource.new.bucket(registry_stack.parameter('RepoS3'))

  Facter.add('registry_endpoint') do
    setcode do
      registry_stack.parameter('RegistryEndpoint')
    end
  end

  Facter.add('registry_storage_bucket') do
    setcode do
      registry_stack.resource('NemesisDockerRegistryBucket').physical_resource_id
    end
  end

  Facter.add('registry_storage_region') do
    setcode do
      AwsHelper.region
    end
  end

  endpoint = registry_stack.parameter('RegistryEndpoint')

  Facter.add('registry_ssl_certificate') do
    setcode do
      registry_certificates_bucket.object("certs/#{endpoint}/domain.crt").get.body.read
    end
  end

  Facter.add('registry_admin_password') do
    setcode do
      registry_stack.parameter('RegistryAdminPassword')
    end
  end

  if Facter.value('server_type') == 'docker-registry'
    Facter.add('registry_ssl_key') do
      setcode do
        registry_certificates_bucket.object("certs/#{endpoint}/domain.key").get.body.read
      end
    end
  end
end
