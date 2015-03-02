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
    desc 'build STACK', 'Build the Nemesis Puppet deb'
    method_option :build_repo, :aliases => '-b', :type => :boolean, :default => true, :desc => 'After creating the package rebuild the repo'
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => 'The GPG key used to sign the packages'
    method_option :release, :aliases => '-r', :type => :boolean, :default => false, :desc => 'Set this flag to build a release package'
    method_option :release_version, :type => :string, :default => '', :desc => 'Explicitly specify semantic version with format MAJOR.MINOR.PATCH for release build'
    method_option :cleanup, :type => :boolean, :default => true, :desc => 'Do not delete older versions when building a release package'
    def build(stack_name = Nemesis::DEFAULT_BOOTSTRAP_REPO)
      NemesisOps::Puppet.build(stack_name, options)
    end

    desc 'kick STACK', 'Trigger a Puppet run using the latest nemesis-puppet package'
    def kick(stack)
      cluster = Nemesis::Entities::Cluster.new(stack)
      cluster.ssh.parallel_exec('apt-get update && apt-get install -y nemesis-puppet')
      result = cluster.ssh.parallel_exec('cd /etc/puppet && puppet apply manifests/nodes.pp')
      result.each do |server_result|
        Nemesis::Log.info(server_result.first)
      end
    end
  end
end
