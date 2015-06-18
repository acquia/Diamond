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

require 'yaml'
require 'ostruct'

module NemesisOps::PackerGen
  class Config
    class InvalidBuilderException < StandardError; end

    def initialize(config)
      if config && File.exist?(config)
        @config = Psych.load(File.read(config))
        @config.each do |key, value|
          @config[key] = OpenStruct.new(value)
        end
      else
        @config = { aws: OpenStruct.new }
      end

      types.each do |type|
        self.class.send(:define_method, type.to_s) { @config[type] }
      end
    end

    def get(type, key)
      if respond_to? type.to_s
        send(type)[key]
      else
        raise InvalidBuilderException.new("Unknown builder #{type} in config")
      end
    end

    def [](type)
      send(type)
    end

    def types
      @config.keys
    end
  end
end
