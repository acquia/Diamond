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
require 'tempfile'

require 'nemesis'

module NemesisOps::Cli
  class Ami < Thor
    def self.common_ami_template_options
      # Required
      method_option :tag, aliases: '-t', type: :string, required: true, desc: 'A tag to apply to use to find the AMI when launching in Nemesis'
      # Optional
      method_option :ami, aliases: '-a', type: :string, required: false, default: NemesisOps::DEFAULT_AMI, desc: "AMI to use as the base AMI, Default: #{NemesisOps::DEFAULT_AMI}"
      method_option :regions, type: :array, required: false, default: ['us-east-1'], desc: 'A list of regions to copy the resulting AMI to'
    end

    desc 'gen OPTIONS', 'Get a Packer-compatable template for building an AMI'
    common_ami_template_options
    def gen(output_file = nil)
      template = NemesisOps::Ami.generate_template(options)

      if output_file
        File.write(output_file, template.to_json)
      else
        say template.to_json
      end
    end

    desc 'build OPTIONS', 'Generate and build an AMI'
    common_ami_template_options
    method_option :debug, aliases: '-d', type: :boolean, required: false, default: false, desc: 'Debug the AMI build'
    def build(repo)
      options[:repo] = repo
      template = NemesisOps::Ami.generate_template(options)
      build_ami(template, options[:tag], options[:debug])
    end

    desc 'list REPO', "List all AMI's avilable in a current repo"
    def list(repo)
      images = Nemesis::Aws::Sdk::EC2.new.images
      amis = images.tagged(repo)

      ami_list = [['Instance ID', 'Tags']]
      amis.each do |ami|
        tags = ami.tags.to_h.keys.reject { |k| ['nemesis', repo].include?(k) }
        ami_list << [ami.id, tags.join(',')]
      end

      print_table(ami_list)
    end

    no_tasks do
      # Check to determine if an AMI id is available or not
      #
      # @param id [String] - AMI id
      # @return boolean
      def ami_exists?(id)
        Nemesis::Aws::Sdk::EC2::Image.new(id).exists?
      end

      # Build a AMI using packer from a given template
      def build_ami(template, tag, debug = false)
        # make sure packer is installed and available in the PATH
        unless ENV['PATH'].split(':').any? { |dir| File.executable?(File.join(dir, 'packer')) }
          fail Thor::Error, 'Unable to find packer application in your PATH'
        end

        # Make sure the source AMI is available before trying to create the new AMI
        unless ami_exists?(options[:ami])
          fail Thor::Error, "Unable to find given AMI #{options[:ami]}"
        end

        # Create a tempfile and use it to build the ami
        begin
          ami_file = Tempfile.new(["#{tag}-ami", '.json'])
          ami_file.write(template.to_json)
          ami_file.rewind
          ami_file.close

          debug_flag = debug ? '-debug' : ''

          system("packer build #{debug_flag} #{ami_file.path}", out: $stdout, err: :out)
        rescue
          say "An error occurred while trying to build #{ami_file.path}"
        ensure
          ami_file.unlink
        end
      end
    end
  end
end
