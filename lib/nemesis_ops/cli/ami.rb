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

require 'multi_json'
require 'oj'
require 'packer_gen'

require 'nemesis'

module NemesisOps::Cli
  class Ami < Thor
    include NemesisOps::Cli::Common

    desc 'template CONFIG', 'Get a Packer-compatable template for building an AMI'
    def template(config)
      unless File.exists? File.absolute_path(config)
        say "Configuration file #{config} does not exist"
        exit 1
      end
      template = PackerGen::Templates::Aws::UbuntuServer.new(config, 'm3.medium')
      say template.to_json
    end

  end
end
