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
require 'fileutils'
describe NemesisOps::Puppet::ModuleCredentials do

  describe '.path' do
    it 'raises an error if a SECURE directory is not defined' do
      ENV['SECURE'] = nil
      expect { described_class.path }.to raise_error
    end

    it 'raises an error if an EC2_ACCOUNT is not defined' do
      ENV['SECURE'] = 'test'
      ENV['EC2_ACCOUNT'] = nil
      expect { described_class.path }.to raise_error
    end

    it 'yields a correct path' do
      ENV['SECURE'] = 'test'
      ENV['EC2_ACCOUNT'] = 'my-account'
      expected_path = Pathname.new('test/nemesis/my-account')
      expect(described_class.path).to eq(expected_path)
    end
  end

  it 'collects yaml files from the SECURE directory' do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do |d|
        files = 5.times.map { |_| "#{Faker::App.name.gsub(' ', '_').downcase}.yaml" }.uniq
        files.each do |file|
          File.open(file, 'w'){|f| f.print "---\ntest_data: #{Faker::Company.catch_phrase}"}
        end
        allow(described_class).to receive(:path).and_return(Pathname.new(Dir.pwd))
        creds = described_class.new
        expect(creds.creds.keys).to match_array(files.map{|f| File.basename(f, '.yaml')})
      end
    end
  end
end
