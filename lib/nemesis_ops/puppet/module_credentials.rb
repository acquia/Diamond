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

require 'yaml'
module NemesisOps::Puppet
  class ModuleCredentials
    attr_reader :creds
    def initialize
      @creds = {}
      creds_files = Dir.glob(NemesisOps::Puppet::ModuleCredentials.path + '*.yaml')
      creds_files.each do |file|
        @creds[File.basename(file, '.yaml')] = Psych.load(File.read(file))
      end
    end

    # Get the path to the nemesis credential directory
    # @return [Pathname] the path to the credentials directory
    def self.path
      if ENV['SECURE'].nil?
        fail 'You need to export an environment variable called SECURE that points to the location of your credentials directory'
      end

      if ENV['EC2_ACCOUNT'].nil?
        fail 'You need to export an environment variable called EC2_ACCOUNT that specifies the EC2_ACCOUNT you want to use'
      end

      Pathname.new(ENV['SECURE']) + 'nemesis' + ENV['EC2_ACCOUNT']
    end
  end
end
