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

require 'gpgme'
require 'tempfile'

module NemesisOps::Gpg
  # Create a GPG key and keyring in a directory
  #
  # @param directory_path [String] path to a directory
  def self.create_gpg_keyring(directory_path)
    params = <<PARAMS
Key-Type: 1
Key-Length: 2048
Subkey-Type: 1
Name-Real: nemesis-puppet
Name-Email: platform-health@acquia.com
Expire-Date: 0
PARAMS
    file = Tempfile.new('key_opts')
    file.write(params)
    file.close
    cmd = "GNUPGHOME=#{directory_path} gpg --batch --gen-key #{file.path} 2>&1"
    `#{cmd}`
    file.unlink
  end

  # Get the key id of a GPG key
  #
  # @param path [String] the path to a gpg keyring
  # @param key_name [String] the key name to look up
  # @return [String] the key's fingerprint
  def self.gpg_key_id(path, key_name = 'platform-health@acquia.com')
    GPGME::Engine.home_dir = path.to_s
    key = GPGME::Key.find(:public, key_name).first
    key.fingerprint
  end

  # Encrypt a string using eyaml
  #
  # @param key_name [String] the name of a gpg key
  # @param data [String] a value to encrypt
  # @return [String] eyaml-compliant encrypted data
  def self.encrypt_string(key_name, data, key_path: nil)
    cmd = "eyaml encrypt -n gpg --gpg-recipients #{key_name} -o string -s \"#{data}\""
    cmd << " --gpg-gnupghome #{key_path}" if key_path
    result = `#{cmd}`
    result.chomp
  end

  # Encrypt a hash using eyaml
  #
  # @param key_name [String] the name of a gpg key to use
  # @param data [Hash] a hash of data to encrypt
  def self.encrypt_hash(key_name, data, key_path: nil)
    data.reduce({}) do |acc, (key, value)|
      if value.class == Hash
        acc[key] = encrypt_hash(key_name, value, key_path: key_path)
      else
        acc[key] = NemesisOps::Gpg.encrypt_string(key_name, value, key_path: key_path)
      end
      acc
    end
  end
end
