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
require 'semantic'

module NemesisOps::Cli
  class Puppet < Thor
    include NemesisOps::Cli::Common

    desc "build STACK", "Build the Nemesis Puppet deb"
    method_option :build_repo, :aliases => '-b', :type => :boolean, :default => true, :desc => "After creating the package rebuild the repo"
    method_option :gpg_key, :type => :string, :default => NemesisOps::GPG_KEY, :desc => "The GPG key used to sign the packages"
    method_option :release, :aliases => '-r', :type => :boolean, :default => false, :desc => "Set this flag to build a release package"
    method_option :release_version, :type => :string, :default => "", :desc => "Explicitly specify semantic version with format MAJOR.MINOR.PATCH for release build"
    method_option :cleanup, :type => :boolean, :default => true, :desc => "Do not delete older versions when building a release package"
    def build(stack_name = Nemesis::DEFAULT_BOOTSTRAP_REPO)

      options[:release] = true unless options[:release_version].empty?
      version = Semantic::Version.new(`git describe --abbrev=0 --tags`.strip)
      Nemesis::Log.info('Syncing package mirror')
      get_repo(stack_name)

      # Find highest version available
      puppet_packages = Dir.glob(NemesisOps::Cli::Common::CACHE_DIR.join("*.deb")).select{|package| package.match("nemesis-puppet_")}
      unless puppet_packages.empty?
        version = puppet_packages.reduce(version) do |a, e|
          rev = Semantic::Version.new(e.match(/nemesis-puppet_((\d+\.?)+)/)[1])
          a = rev > a ? rev : a
        end
      end

      build_time = DateTime.now
      if options[:release]
        version = version.increment!(:patch)
        Nemesis::Log.info("Bumping version to #{version.to_s}")
      else
        version = Semantic::Version.new("#{version}+#{build_time.strftime("%s")}")
      end

      clean_repo(stack_name) if options[:cleanup]

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
              " -v #{version}" \
              " --vendor 'Acquia, Inc.'" \
              " --depends puppet" \
              " -m 'hosting-eng@acquia.com'" \
              " --description \"Acquia #{version} built on #{build_time.to_s}\" " \
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

    private
    def clean_repo(stack_name)
        Nemesis::Log.info("Cleaning out s3/aptly/local-cache")
        s3 = Nemesis::Aws::Sdk::S3.new
        repo = s3.buckets[get_bucket_from_stack(stack_name, 'repo')]
        #Find deletable devel packages in the bucket
        s3_del_candidates = repo.objects.select{|package| package.key =~ /nemesis-puppet.*\.deb/}
        #Delete packages from bucket
        s3_del_candidates.map(&:delete)
        #Cleanup aptly's pool. Packages which are not referenced in any repo are deleted.
        Dir.chdir(REPO_DIR) do |d|
          aptly "db cleanup"
        end
        #Find packages and delete from local-cache.
        puppet_del_packages = Dir.glob(NemesisOps::Cli::Common::CACHE_DIR.join("*.deb")).select{|package| package =~ /nemesis-puppet.*\.deb/}
        FileUtils.rm(puppet_del_packages)
    end
  end
end
