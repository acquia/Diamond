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

module NemesisOps::Cli
  class Puppet < Thor
    desc 'build STACK_NAME', 'Build the Nemesis Puppet deb'
    method_option :build_repo, :aliases => '-b', :type => :boolean, :default => true, :desc => 'After creating the package rebuild the repo'
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => 'The GPG key used to sign the packages'
    method_option :release, :aliases => '-r', :type => :boolean, :default => false, :desc => 'Set this flag to build a release package'
    method_option :release_version, :type => :string, :default => '', :desc => 'Explicitly specify semantic version with format MAJOR.MINOR.PATCH for release build'
    method_option :cleanup, :type => :boolean, :default => true, :desc => 'Do not delete older versions when building a release package'
    def build(stack_name)
      NemesisOps::Puppet.build(stack_name, options)
    end

    desc 'kick STACK_NAME SERVER_TYPE', 'Trigger a Puppet run using the latest nemesis-puppet package'
    method_option :parallel, :type => :boolean, :default => false, :desc => 'Run commands in parallel'
    method_option :debug, :type => :boolean, :default => false, :desc => 'Output debug information'
    def kick(stack_name, server_type = nil)
      cluster = Nemesis::Entities::Cluster.new(stack_name, nil)

      if cluster.servers.size == 0
        Nemesis::Log.error("Stack #{stack_name} with server type #{server_type} returned 0 servers")
        exit 1
      end

      if options[:parallel]
        cluster.ssh.parallel_exec('apt-get update && apt-get install -y nemesis-puppet')
        result = cluster.ssh.parallel_exec('/usr/local/bin/run_puppet')
        result.each { |server_result| Nemesis::Log.info(server_result.first) }  if options[:debug]
      else
        cluster.servers.each do |server|
          Nemesis::Log.info("Updating server #{server.ip_address}")
          server.exec('apt-get update && apt-get install -y nemesis-puppet')
          result = server.exec('/usr/local/bin/run_puppet')
          Nemesis::Log.info(result) if options[:debug]
        end
      end
    end
  end
end
