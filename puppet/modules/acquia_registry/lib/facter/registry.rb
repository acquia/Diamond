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
require 'nemesis_aws_client'

ec2 = AWS::EC2.new
cf = NemesisAwsClient::CloudFormation.new
stack = cf.stack_resource(Facter.value('ec2_instance_id')).stack

if !stack.parameters['RegistryStack'].nil? || ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'docker-registry'

  s3 = NemesisAwsClient::S3.new
  registry_stack_name = stack.parameters['RegistryStack'] || stack.name
  registry_stack = cf.stacks[registry_stack_name]
  parameters = registry_stack.parameters
  registry_certificates_bucket = s3.buckets[parameters['RepoS3']]
  registry_endpoint = parameters['RegistryEndpoint']

  Facter.add('registry_endpoint') do
    setcode do
      registry_endpoint
    end
  end

  Facter.add('registry_storage_bucket') do
    setcode do
      registry_stack.resources['NemesisDockerRegistryBucket'].physical_resource_id
    end
  end

  Facter.add('registry_storage_region') do
    setcode do
      s3.config.region
    end
  end

  Facter.add('registry_ssl_certificate') do
    setcode do
      registry_certificates_bucket.objects["certs/#{registry_endpoint}/domain.crt"].read
    end
  end

  Facter.add('registry_admin_password') do
    setcode do
      parameters['RegistryAdminPassword']
    end
  end

  if Facter.value('server_type') == 'docker-registry'
    Facter.add('registry_ssl_key') do
      setcode do
        registry_certificates_bucket.objects["certs/#{registry_endpoint}/domain.key"].read
      end
    end
  end
end
