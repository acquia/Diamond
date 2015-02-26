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
    desc 'template', 'Get a Packer-compatable template for building an AMI'
    method_option :repo, alias: '-r', type: 'string', default: nil, desc: 'Stack to write the AMI to'
    method_option :regions, type: :array, required: true, desc: 'A list of regions to copy the resulting AMI to'
    method_option :tag, type: :string, required: true, desc: 'A tag to apply to use to find the AMI when launching in Nemesis'
    def template
      template = NemesisOps::Ami.generate_template(options)
      say template.to_json
    end
  end
end
