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

module NemesisOps::Puppet
  class GpgKeyNotFound < StandardError; end

  def self.gpg_struct
    Struct.new(:pub_key, :private_key)
  end

  def self.get_gpg_key_data(key_name)
    pub_key = GPGME::Key.find(:public, key_name)
    if pub_key.empty?
      fail GpgKeyNotFound, "Unable to find the key #{key_name}"
    end

    private_key = GPGME::Key.find(:secret, key_name)
    if private_key.empty?
      fail GpgKeyNotFound, "Unable to find the private key #{key_name}"
    end

    pub_key = pub_key.first.export.to_s
    # Workaround for GPGME not being able to export private keys
    private_key = `gpg --export-secret-key --armor #{key_name}`

    gpg_struct.new(pub_key, private_key)
  end

  def self.create_gpg_key_package(data, version)
    Dir.mktmpdir do |tmp|
      pub_key_temp = Tempfile.new('key.gpg', binmode: true)
      pub_key_temp.write(data.pub_key)
      pub_key_temp.close

      priv_key_temp = Tempfile.new('p_key.gpg')
      priv_key_temp.write(data.private_key)
      priv_key_temp.close

      puts `GNUPGHOME=#{tmp} gpg --no-default-keyring --keyring=#{tmp}/pubring.gpg --secret-keyring=#{tmp}/secring.gpg --import #{pub_key_temp.path}`
      puts `GNUPGHOME=#{tmp} gpg --no-default-keyring --keyring=#{tmp}/pubring.gpg --secret-keyring=#{tmp}/secring.gpg --allow-secret-key-import --import --armor #{priv_key_temp.path}`

      pub_key_temp.unlink
      priv_key_temp.unlink

      build_time = DateTime.now
      cli = 'fpm' \
            ' --force' \
            " -C #{tmp}" \
            ' -s dir' \
            ' -t deb' \
            ' -n nemesis-key'\
            " -v #{version}" \
            ' --vendor \'Acquia, Inc.\'' \
            ' -m \'platform-health@acquia.com\'' \
            " --description \"Acquia #{version} built on #{build_time.to_s}\" " \
            ' --prefix /var/lib/puppet/.gnupg' \
            ' .'
      Nemesis::Log.info(cli)
      result = `#{cli}`
      Nemesis::Log.info(result)
      # Really unsafe
      result = eval(result)
      FileUtils.mv(result[:path], NemesisOps::Cli::Common::CACHE_DIR)
    end
  end
end
