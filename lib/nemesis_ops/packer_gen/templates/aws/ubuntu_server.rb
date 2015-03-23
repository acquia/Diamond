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

module NemesisOps::PackerGen::Templates::Aws
  class UbuntuServer < NemesisOps::PackerGen::PackerTemplate
    include NemesisOps::PackerGen::Templates::Aws::AwsTemplate

    def initialize(config = nil, server_type = 'm3.medium')
      super(config)
      @server_type = server_type
      scripts
      builder
    end

    def scripts
      @provisioners.add(get_aws_tools)
    end

    def builder
      defaults = {
        type: 'amazon-instance',
        ssh_username: 'ubuntu',
        x509_upload_path: '/tmp',
        ami_virtualization_type: 'hvm',
        source_ami: 'ami-9aaa1cf2',
        region: 'us-east-1',
        ami_name: "#{self.class.name.split('::').last}_{{ timestamp }}",
        instance_type: @server_type,
      }.merge(config[type].to_h)

      @builders.add(defaults)
    end
  end
end
