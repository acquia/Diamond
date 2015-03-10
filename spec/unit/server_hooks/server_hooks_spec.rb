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

require_relative '../../../puppet/modules/server_hooks/files/nemesis_server_hooks.rb'
require_relative 'example_hooks/hook_one.rb'

require 'tmpdir'

describe NemesisServer::HookManager do
  before :each do
    
    @tmp_log_location = Dir.mktmpdir "nemesis_log"
    @tmp_lock_location = Dir.mktmpdir "nemesis_lock"

    @manager = NemesisServer::HookManager.new @tmp_log_location

    @manager.lock_location = @tmp_lock_location
    NemesisServer::HookManager.instance = @manager

    @hook_one = HookOne.new
  end

  describe 'instance' do
    it 'should be able to retrieve the instance' do
      expect(NemesisServer::HookManager.instance).not_to be_nil
    end
  end

  describe 'eligibility' do
    it 'should be able to determine eligibility for init' do
      @hook_one.events = NemesisServer::HookManager::EVENT_INIT
      @hook_one.set_default_lock_info
      expect(@manager.eligible?(@hook_one)).to be true
      @hook_one.lock_info['exec_count'] = 1
      expect(@manager.eligible?(@hook_one)).to be false
    end

    it 'should be able to determine eligibility for update' do
      @hook_one.events = NemesisServer::HookManager::EVENT_UPDATE
      @hook_one.set_default_lock_info
      @hook_one.version = '0.0.1'
      @hook_one.lock_info['hook_version'] = '0.0.1'
      expect(@manager.eligible?(@hook_one)).to be false
      @hook_one.version = '0.0.2'
      expect(@manager.eligible?(@hook_one)).to be true
    end

    it 'should be able to determine eligibility for repeat' do
      @hook_one.events = NemesisServer::HookManager::EVENT_REPEAT
      @hook_one.set_default_lock_info
      @hook_one.interval = 30
      @hook_one.lock_info['last_run'] = Time.now.to_i
      expect(@manager.eligible?(@hook_one)).to be false
      @hook_one.lock_info['last_run'] -= 60
      expect(@manager.eligible?(@hook_one)).to be true
    end

    it 'should not allow hooks to run after max errors' do
      @hook_one.set_default_lock_info
      expect(@manager.eligible?(@hook_one)).to be true
      @hook_one.lock_info['consecutive_error_count'] = @hook_one.max_consecutive_errors
      expect(@manager.eligible?(@hook_one)).to be false
      @hook_one.lock_info['consecutive_error_count'] = 0
    end
  end

  describe 'locking and executing' do
    it 'should be able to lock/unlock the hook correctly and write its state' do
      @hook_one.set_default_lock_info
      @manager.lock_file @hook_one
      expect(File.exist?(@manager.lock_file_path(@hook_one)))

      @manager.unlock_file @hook_one
      contents = File.read(@manager.lock_file_path(@hook_one))
      info = JSON.parse contents
      expect(info['last_run']).to eq 0
      expect(info['hook_exit']).to eq -1
      expect(info['exec_count']).to eq 0
      expect(info['hook_version']).to eq '0.0.0'
      expect(info['api_version']).to eq '0.0.0'
    end

    it 'should be able to register, execute and write the hook state' do
      @manager.remove_hooks
      NemesisServer::HookManager.register @hook_one
      expect(@manager.hooks.count).to be 1
      @manager.execute_hooks
      contents = File.read(@manager.lock_file_path(@hook_one))
      info = JSON.parse contents
      expect(info['last_run']).to be > 0
      expect(info['hook_exit']).to eq 0
      expect(info['exec_count']).to eq 1
      expect(info['consecutive_error_count']).to eq 0
      expect(info['hook_version']).not_to be_nil
      expect(info['api_version']).not_to be_nil
    end

    it 'should be able to scan for hooks and execute, saving the proper lock info' do
      spec_path = File.dirname(__FILE__)
      @manager.hook_location = "#{spec_path}/example_hooks/"
      @manager.hooks = []
      @manager.run
      contents = File.read(@manager.lock_file_path(@manager.hooks.last))
      info = JSON.parse contents
      expect(info['last_run']).to be > 0
      expect(info['hook_exit']).to eq 1
      expect(info['exec_count']).to eq 0
      expect(info['consecutive_error_count']).to eq 1
      expect(info['hook_version']).not_to be_nil
      expect(info['api_version']).not_to be_nil

      # When the exit code is 0, it should increment the exec_count and write version info.
      @manager.hooks.last.exit_code = 0
      @manager.hooks.last.version = '0.0.3'
      @manager.execute_hooks
      contents = File.read(@manager.lock_file_path(@manager.hooks.last))
      info = JSON.parse contents
      expect(info['hook_exit']).to eq 0
      expect(info['exec_count']).to eq 1
      expect(info['consecutive_error_count']).to eq 0
      expect(info['hook_version']).to eq @manager.hooks.last.version
    end
  end
end
