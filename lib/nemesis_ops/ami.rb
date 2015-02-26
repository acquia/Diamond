# Copyright 2014 Acquia, Inc.
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

require 'nemesis'

module NemesisOps
  module Ami
    extend NemesisOps::Common

    # Create a script that Packer can use to install dependencies for an AMI
    #
    # @return [String]
    def self.get_dependencies_for_packer
      init = Nemesis::Aws::CloudFormation::Init.new(omit: [/puppet/])
      packages = init.steps['bootstrap']['packages']['apt'].keys
      gems = init.steps['bootstrap']['packages']['rubygems'].keys
      [
        "sudo -E apt-get install -y #{packages.join(' ')}",
        "sudo gem install --no-ri --no-rdoc #{gems.join(' ')}"
      ]
    end

    # Generate a complete Packer template for building an AMI
    #
    # @param config [String] the path to a YAML configuration file
    # @param options [Hash] options passed through Thor
    # @return [PackerGen::Templates::Aws::UbuntuServer]
    def self.generate_template(options)
      keys = Nemesis::Credentials.create.creds_for_machine('ec2.client')
      account_id = Nemesis::Credentials.create.creds_for_machine('ec2.account.id').password
      template = PackerGen::Templates::Aws::UbuntuServer.new(nil, 'm3.medium')

      fail 'Cannot read from netrc' if Net::Netrc.rcname.nil?
      secure_path = File.dirname(Net::Netrc.rcname)

      launch_region = options[:regions].shift

      # Insert all of the arguments
      template.builders[0][:region] = launch_region
      template.builders[0][:access_key] = keys.login
      template.builders[0][:secret_key] = keys.password
      template.builders[0][:account_id] = account_id
      template.builders[0][:x509_cert_path] = "#{secure_path}/cert.pem"
      template.builders[0][:x509_key_path] = "#{secure_path}/pk.pem"
      template.builders[0][:s3_bucket] = File.join(get_bucket_from_stack(options[:repo], 'repo'), 'images') if options[:repo]
      template.builders[0][:tags] = { options[:tag] => nil }
      template.builders[0][:ami_regions] = options[:regions] unless options[:regions].empty?

      template.provisioners.add(
        {
          type: 'shell',
          inline: NemesisOps::Ami.get_dependencies_for_packer
        }
      )
      template
    end
  end
end
