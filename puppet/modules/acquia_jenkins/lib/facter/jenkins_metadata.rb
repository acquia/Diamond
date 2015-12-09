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

# The jenkins_cli_pub_key fact reports the contents of the public key that is
# used to execute jenkins cli commands as admin. This fact will create the key
# if it does not yet exist. It would be preferable to create the key as a puppet
# resource, but it needs to be available on init.
Facter.add('jenkins_cli_pub_key') do
  setcode do
    # If the key does not exist yet, create it.
    unless File.exist?('/var/lib/jenkins/.ssh/jenkins_cli.pub')
      `mkdir -p /var/lib/jenkins/.ssh && /usr/bin/ssh-keygen -b 2048 -f /var/lib/jenkins/.ssh/jenkins_cli -t rsa -N ''`
    end
    `/bin/cat /var/lib/jenkins/.ssh/jenkins_cli.pub`.chomp!
  end
end

if AwsHelper.server_type_is?('jenkins')
  stack = AwsHelper.stack

  Facter.add('jenkins_password') do
    setcode do
      stack.parameter('JenkinsPassword')
    end
  end

  Facter.add('jenkins_email') do
    setcode do
      stack.parameter('JenkinsEmail')
    end
  end

  Facter.add('jenkins_url') do
    setcode do
      stack.parameter('JenkinsURL') || Facter.value('ec2_public_hostname')
    end
  end
end
