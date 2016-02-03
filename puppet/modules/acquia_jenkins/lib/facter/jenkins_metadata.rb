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
require 'secrets_helper'

if AwsHelper.server_type_is?('jenkins')
  stack = AwsHelper.stack

  secrets = SecretsHelper.new(stack)
  if secrets.enabled?
    Facter.add('jenkins_github_oauth_key') do
      setcode do
        secrets.get('jenkins/github-oauth-key')
      end
    end

    # To configure GITHUB authentication to work we will need to
    # have both GITHUB CLIENT ID and GITHUB CLIENT SECRET.
    Facter.add('jenkins_github_client_id') do
      setcode do
        secrets.get('jenkins/github-client-id')
      end
    end

    Facter.add('jenkins_github_client_secret') do
      setcode do
        secrets.get('jenkins/github-client-secret')
      end
    end

    Facter.add('jenkins_zk_ui_password') do
      setcode do
        secrets.get('jenkins/zk-ui-password')
      end
    end

    Facter.add('nemesis_secret_key') do
      setcode do
        secrets.get('jenkins/nemesis-secret-key')
      end
    end
  end

  Facter.add('aws_region') do
    setcode do
      Facter.value('ec2_placement_availability_zone')[0..-2]
    end
  end

  Facter.add('jenkins_default_ami') do
    setcode do
      secrets.get('jenkins/default-ami-id')
    end
  end

  Facter.add('jenkins_url') do
    setcode do
      stack.parameter('JenkinsURL') || Facter.value('ec2_public_hostname')
    end
  end
end
