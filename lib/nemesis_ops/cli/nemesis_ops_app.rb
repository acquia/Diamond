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

require 'thor'
require 'nemesis_ops'

module NemesisOps::Cli

  class NemesisOpsApp < Thor
    desc "version", "Display current version"
    def version
      say "#{NemesisOps::VERSION}"
    end

    desc 'ami SUBCOMMANDS ...ARGS', 'manage all things related to AMIs'
    subcommand 'ami,', Ami

    desc "package SUBCOMMANDS ...ARGS", "manage all things related to packages"
    subcommand 'package', Package

    desc "puppet SUBCOMMANDS ...ARGS", "manage all things related to puppet"
    subcommand 'puppet', Puppet
  end
end

