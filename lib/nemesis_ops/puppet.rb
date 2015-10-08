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

require 'gpgme'
require 'tempfile'
require 'yaml'

module NemesisOps::Puppet
  require_relative 'puppet/module_credentials'
  require_relative 'puppet/version'

  extend NemesisOps::Common

  # Build a .deb package containing all of the Puppet modules in the project
  # This also will pull in any encrypted credentials that should be placed on a
  # server by encrypting eyaml files with a gpg key unique to this build
  #
  # @param stack_name [String] the name of the stack this package should be synced against
  # @param options [Hash] options from the Thor command
  def self.build(stack_name, options)
    options[:release] = true unless options[:release_version].empty?
    Nemesis::Log.info('Syncing package mirror')
    get_repo(stack_name)

    build_time = DateTime.now
    version = get_package_version(stack_name, build_time, release: options[:release])
    Nemesis::Log.info("Bumping version to #{version}")

    remove_package(stack_name, 'nemesis-puppet', options[:gpg_key]) if options[:cleanup]

    Nemesis::Log.info('Updating puppet 3rd party modules')
    Nemesis::Log.info(`librarian-puppet install`)

    Dir.mktmpdir do |dir|
      # Copy over the puppet subdirectory
      FileUtils.cp_r(NemesisOps::BASE_PATH.join('puppet'), dir)

      # Create a unique gpg key for this run
      eyaml_gpg = Pathname.new(dir) + 'puppet/.gnupg'
      eyaml_dir = Pathname.new(dir) + 'puppet/hiera'
      FileUtils.mkdir_p(eyaml_gpg, :mode => 0700)
      NemesisOps::Gpg.create_gpg_keyring(eyaml_gpg)

      # Get any credential files that should be put on the server as eyaml
      encrypted_credentials = NemesisOps::Puppet.encrypted_hiera_files(eyaml_gpg)

      unless encrypted_credentials.empty?
        encrypted_credentials.each do |filename, data|
          File.open(eyaml_dir + filename, 'w') { |f| f.print data }
        end
      end

      cli = 'fpm' \
        ' --force' \
        " -C #{dir + '/puppet'}" \
        ' -s dir' \
        ' -t deb' \
        ' -n nemesis-puppet'\
        " -v #{version}" \
        " --vendor 'Acquia, Inc.'" \
        ' --depends puppet' \
        " -m 'hosting-eng@acquia.com'" \
        " --description \"Acquia #{version} built on #{build_time}\" " \
        ' --prefix /etc/puppet/' \
        ' .'

      Nemesis::Log.info(cli)
      result = `#{cli}`
      Nemesis::Log.info(result)
      # Really unsafe
      result = eval(result)
      FileUtils.mv(result[:path], NemesisOps::PKG_CACHE_DIR.join(stack_name))
    end

    build_repo(stack_name, options[:gpg_key]) if options[:build_repo]
  end

  # Generate a set of eyaml hiera files using data from the $SECURE directory
  #
  # @param key_path [String] the path to a temporary gpg keyring
  # @return [Hash] eyaml files keyed by filename
  def self.encrypted_hiera_files(key_path)
    creds = NemesisOps::Puppet::ModuleCredentials.new
    encrypted_creds = {}

    key_id = NemesisOps::Gpg.gpg_key_id(key_path)
    Dir.mktmpdir do |dir|
      creds.creds.each do |key, data|
        encrypted_creds[key + '.eyaml'] = Psych.dump(NemesisOps::Gpg.encrypt_hash(key_id, data, key_path: key_path))
      end
    end
    encrypted_creds
  end

  # Get a package version to apply to this nemesis-puppet build
  #
  # @param stack_name [String] name of the stack
  # @param build_time [DateTime] the time to apply to the build
  # @param release [Boolean] whether or not this is a release build
  # @return [String] the version to apply to the package
  def self.get_package_version(stack_name, build_time, release: false)
    version = NemesisOps::Puppet::Version.new(`git describe --abbrev=0 --tags`.strip)

    # Find highest version available
    puppet_packages = Dir.glob(NemesisOps::PKG_CACHE_DIR.join(stack_name, '*.deb')).select { |package| package.match('nemesis-puppet_') }
    unless puppet_packages.empty?
      version = puppet_packages.reduce(version) do |a, e|
        rev = NemesisOps::Puppet::Version.new(e.match(/nemesis-puppet_((\d+\.?)+)/)[1])
        a = rev > a ? rev : a
      end
    end
    if release
      version = version.increment!(:patch)
    else
      version = NemesisOps::Puppet::Version.new("#{version}+#{build_time.strftime('%s')}")
    end
    version
  end
end
