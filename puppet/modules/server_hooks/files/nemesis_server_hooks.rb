#!/usr/bin/env ruby

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

require 'json'
require 'logger'

module NemesisServer
  # rubocop:disable ClassLength
  class HookManager
    EVENT_INIT = 1
    EVENT_UPDATE = 2
    EVENT_REPEAT = 4

    attr_accessor :lock_info, :hooks, :log
    attr_accessor :api_version, :hook_location, :resource_location, :lock_location, :log_location

    @instance = nil
    class << self
      attr_accessor :instance
    end

    # Creates a new NemesisServer::HookManager instance.
    def initialize(log_location = '/var/log/nemesis/', log_level = Logger::DEBUG)
      @api_version = '0.0.1'
      @hook_location = '/etc/nemesis/server_hooks/'
      @resource_location = '/etc/nemesis/resources/'
      @lock_location = '/var/lock/nemesis/'
      init_logger log_location, log_level

      @hooks = []
    end

    # Initiate the logger object
    def init_logger(log_location = '/var/log/nemesis/', log_level = Logger::DEBUG)
      path = File.join(log_location, '')
      @log = Logger.new("#{path}server_hooks.log")
      @log.level = log_level
    end

    # Removes all hooks in memory.
    def remove_hooks
      @hooks = []
    end

    # Loads all hook class files from the specified location.
    def load_hooks
      Dir.chdir @hook_location do
        Dir.glob('*.rb').each do |filename|
          require "#{@hook_location}#{filename}"
        end
      end
    end

    # Executes all loaded hooks.
    def execute_hooks
      @hooks.each do |hook|
        hook.set_default_lock_info
        if hook.respond_to?('execute') && lock_file(hook)
          if eligible? hook
            begin
              @log.info "Executing #{hook.class.name}.execute"
              hook.log = @log
              hook_exit = hook.execute
            rescue => e
              hook_exit = e.message
            end

            hook.lock_info['hook_exit'] = hook_exit
            hook.lock_info['last_run'] = Time.now.to_i
            if hook_exit == 0
              # Only write affirmative information if the hook succeeded.
              hook.lock_info['exec_count'] += 1
              hook.lock_info['consecutive_error_count'] = 0
              hook.lock_info['hook_version'] = hook.version
              hook.lock_info['api_version'] = @api_version
              @log.info "Lock info: #{hook.lock_info}"
            else
              hook.lock_info['consecutive_error_count'] += 1
              @log.error "Hook #{hook.class.name} exited with code #{hook_exit}"
            end
          end
          unlock_file hook
        end
      end
    end

    # Determines if the hook has failed too many times in a row.
    def in_error_state?(hook)
      hook.lock_info['consecutive_error_count'] >= hook.max_consecutive_errors
    end

    # Determines if the hook is eligible to be executed and not in an error state.
    def eligible?(hook)
      if eligible_for_init?(hook)
        # Init hooks can only be run if they have a 0 exec_count.
        return !in_error_state?(hook)
      elsif eligible_for_update?(hook)
        # Update hooks can only run if the last executed version is old.
        return !in_error_state?(hook)
      elsif eligible_for_repeat?(hook)
        # Repeat hooks can only run if the specified interval has passed.
        return !in_error_state?(hook)
      end

      false
    end

    # Determines eligibility to execute during an init event.
    def eligible_for_init?(hook)
      hook.events & NemesisServer::HookManager::EVENT_INIT > 0 && hook.lock_info['exec_count'] == 0
    end

    # Determines eligibility to execute during an update event.
    def eligible_for_update?(hook)
      hook.events & NemesisServer::HookManager::EVENT_UPDATE > 0 && Gem::Version.new(hook.version) > Gem::Version.new(hook.lock_info['hook_version'])
    end

    # Determines eligibility to execute during a repeat event.
    def eligible_for_repeat?(hook)
      hook.events & NemesisServer::HookManager::EVENT_REPEAT > 0 && Time.now.to_i - hook.lock_info['last_run'] > hook.interval
    end

    # Locks the hook.
    def lock_file(hook)
      Dir.mkdir(@lock_location, 0700) unless Dir.exist?(@lock_location)
      @lock = File.open(lock_file_path(hook), File::RDWR | File::CREAT, 0644)
      success = @lock.flock(File::LOCK_EX)
      if success
        read_lock_info hook
      else
        @log.error "Could not establish lock for hook '#{hook.class.name}'"
      end
      success
    end

    # Unlocks the hook.
    def unlock_file(hook)
      if @lock.nil?
        @log.error "Could not unlock hook '#{hook.class.name}'"
      else
        write_lock_info hook
        @lock.flock(File::LOCK_UN)
        @lock.close
      end
    end

    # Defines the path to the lock file.
    def lock_file_path(hook)
      path = File.join(@lock_location, '')
      "#{path}#{hook.class.name}"
    end

    # Registers this hook.
    def self.register(hook)
      instance = NemesisServer::HookManager.instance
      hook.api_version = instance.api_version
      hook.hook_location = instance.hook_location
      hook.resource_location = instance.resource_location
      hook.lock_location = instance.lock_location
      instance.hooks.push hook
    end

    # Reads the state info from the lock file.
    def read_lock_info(hook)
      if @lock.nil?
        @log.error "Could not read lock file for '#{hook.class.name}'"
      else
        contents = File.read lock_file_path(hook)
        if contents.length > 2
          info = JSON.parse contents
          hook.lock_info.each do |k, _|
            hook.lock_info[k] = info[k] if info.key?(k)
          end
        end
      end
    end

    # Writes the latest state info to the lock file.
    def write_lock_info(hook)
      if @lock.nil?
        @log.error "Could not write lock file for '#{hook.class.name}'"
      else
        @lock.truncate 0
        @lock.write hook.lock_info.to_json
      end
    end

    # Loads and executes all available hooks.
    def run
      load_hooks
      execute_hooks
    end
  end

  class Hook
    attr_accessor :events, :version, :interval, :max_consecutive_errors
    attr_accessor :api_version, :hook_location, :resource_location
    attr_accessor :lock_location, :lock_info, :log

    # Creates a new NemesisServer::Hook object
    def initialize
      @events = NemesisServer::HookManager::EVENT_INIT | NemesisServer::HookManager::EVENT_UPDATE
      @version = '0.0.1'
      @interval = 30
      @max_consecutive_errors = 3
    end

    # Defines the default state info.
    def set_default_lock_info
      @lock_info = {
        'last_run' => 0,
        'hook_exit' => -1,
        'exec_count' => 0,
        'consecutive_error_count' => 0,
        'hook_version' => '0.0.0',
        'api_version' => '0.0.0'
      }
    end

    # Any class implementing this interface will need to define the execute method.
    def execute
      fail NotImplementedError
    end
  end
end
