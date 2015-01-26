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
    include NemesisOps::Cli::Common

    desc "build STACK", "Build the Nemesis Puppet deb"
    method_option :build_repo, :aliases => '-b', :type => :boolean, :default => true, :desc => "After creating the package rebuild the repo"
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => "The GPG key used to sign the packages"
    def build(stack_name = Nemesis::DEFAULT_BOOTSTRAP_REPO)
      version = '0.9.9.9'

      Nemesis::Log.info('Syncing package mirror')
      get_repo(stack_name)

      # TODO this needs to be fixed
      #puppet_packages = Dir.glob(NemesisOps::Cli::Common::CACHE_DIR.join("/*.deb")).select{|package| package.match("nemesis-puppet_#{version}")}
      #unless puppet_packages.empty?
      #  revision = puppet_packages.reduce(0) do |a, e|
      #    rev = e.match(/nemesis-puppet.*-(.*)_/)[1].to_i
      #    a = rev > a ? rev : a
      #  end
      #  revision += 1
      #else
      #  revision = 1
      #end
      revision = 3

      Nemesis::Log.info('Updating puppet 3rd party modules')
      Nemesis::Log.info(`librarian-puppet install`)

      Dir.mktmpdir do |dir|
        FileUtils.cp_r(NemesisOps::BASE_PATH + 'puppet', dir)
        source = Pathname.new(dir) + 'puppet' + 'third_party'
        files = Dir.glob(source + '*')
        dest = dir + '/puppet' + '/modules'
        FileUtils.mv(files, dest, verbose: true, force: true)
        FileUtils.rm_r(source)
        cli = "fpm" \
              " --force" \
              " -C #{dir + '/puppet'}" \
              " -s dir" \
              " -t deb" \
              " -n nemesis-puppet"\
              " -v #{version}-#{revision}" \
              " --vendor 'Acquia, Inc.'" \
              " --depends puppet" \
              " -m 'hosting-eng@acquia.com'" \
              " --description \"Acquia #{version}-#{revision} built on #{DateTime.now.to_s}\" " \
              " --prefix /etc/puppet/" \
              " ."

        Nemesis::Log.info(cli)
        result = `#{cli}`
        Nemesis::Log.info(result)
        # Really unsafe
        result = eval(result)
        FileUtils.mv(result[:path], NemesisOps::Cli::Common::CACHE_DIR)
      end

      if options[:build_repo]
        build_repo(stack_name, options[:gpg_key])
      end
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
