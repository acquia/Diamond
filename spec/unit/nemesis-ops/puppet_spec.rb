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
describe NemesisOps::Puppet do

  it 'creates encrypted hiera files' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do |d|
        files = 5.times.map { |_| "#{Faker::App.name.gsub(' ', '_').downcase}.yaml" }.uniq
        files.each do |file|
          File.open(file, 'w'){|f| f.print "---\ntest_data: #{Faker::Company.catch_phrase}"}
        end

        Dir.mktmpdir do |gpg_dir|
        allow(NemesisOps::Puppet::ModuleCredentials).to receive(:path).and_return(Pathname.new(Dir.pwd))
          NemesisOps::Gpg.create_gpg_keyring(gpg_dir)
          encrypted_files = described_class.encrypted_hiera_files(gpg_dir)
          module_creds = NemesisOps::Puppet::ModuleCredentials.new
          expect(encrypted_files.keys).to match_array(module_creds.creds.keys.map { |f| "#{f}.eyaml" })
          encrypted_files.each do |filename, data|
            file = File.basename(filename, '.eyaml')
            yaml_data = Psych.load(data)
            decrypted_data = decrypt_string(gpg_dir, yaml_data['test_data'])
            expect(decrypted_data).to eq(module_creds.creds[file]['test_data'])
          end
        end
      end
    end
  end
end
