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

ec2 = NemesisAwsClient::EC2.new

if ec2.instances[Facter.value('ec2_instance_id')].tags.to_h['server_type'] == 'jenkins'
  cf = NemesisAwsClient::CloudFormation.new
  stack = cf.stack_resource(Facter.value('ec2_instance_id'))
  params = stack.stack.parameters

  Facter.add('jenkins_password') do
    setcode do
      params['JenkinsPassword']
    end
  end
end
