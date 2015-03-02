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

require 'faker'
describe NemesisOps::Gpg do

  it 'creates a temporary keyring' do
    Dir.mktmpdir do |tmp|
      NemesisOps::Gpg.create_gpg_keyring(tmp)
      expected_files = %w(pubring.gpg pubring.gpg~ random_seed secring.gpg trustdb.gpg)
      dir_files = Dir.glob("#{tmp}/*").map{ |f| File.basename(f) }
      expect(dir_files).to match_array(expected_files)
    end
  end

  it 'can find the id of a generated key' do
    Dir.mktmpdir do |tmp|
      NemesisOps::Gpg.create_gpg_keyring(tmp)
      id = NemesisOps::Gpg.gpg_key_id(tmp)
      expect(id).not_to be_nil
    end
  end

  it 'can encrypt a string using a gpg key' do
    Dir.mktmpdir do |tmp|
      NemesisOps::Gpg.create_gpg_keyring(tmp)
      id = NemesisOps::Gpg.gpg_key_id(tmp)
      encrypted_data = NemesisOps::Gpg.encrypt_string(id, 'test', key_path: tmp)
      decrypted_data = decrypt_string(tmp, encrypted_data)
      expect(decrypted_data).to eq('test')
    end
  end

  it 'can encrypt a hash using a gpg key' do
    Dir.mktmpdir do |tmp|
      NemesisOps::Gpg.create_gpg_keyring(tmp)
      id = NemesisOps::Gpg.gpg_key_id(tmp)
      hash_data = {data_key: Faker::Hacker.say_something_smart}
      encrypted_data = NemesisOps::Gpg.encrypt_hash(id, hash_data, key_path: tmp)
      expect(encrypted_data.keys).to match_array(%i(data_key))
      decrypted_data = decrypt_string(tmp, encrypted_data[:data_key])
      expect(decrypted_data).to eq(hash_data[:data_key])
    end
  end

  it 'leaves the keys of a hash in plain-text' do
    Dir.mktmpdir do |tmp|
      NemesisOps::Gpg.create_gpg_keyring(tmp)
      id = NemesisOps::Gpg.gpg_key_id(tmp)
      hash_data = {data_key: {test_data: Faker::Company.catch_phrase}}
      encrypted_data = NemesisOps::Gpg.encrypt_hash(id, hash_data, key_path: tmp)
      expect(encrypted_data[:data_key].keys).to match_array(%i(test_data))
    end
  end
end
