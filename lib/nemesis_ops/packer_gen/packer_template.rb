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

require 'psych'
require 'multi_json'
require 'oj'

module NemesisOps::PackerGen
  class PackerTemplate
    attr_accessor :builders, :provisioners, :postprocessors, :variables
    attr_reader :required_keys, :config
    def initialize(config = nil)
      @builders = PackerSection.new(:builders)
      @provisioners = PackerSection.new(:provisioners)
      @postprocessors = PackerSection.new(:postprocessors)
      @variables = PackerSection.new(:variables)
      @config = NemesisOps::PackerGen::Config.new(config)
      @required_keys = []
    end

    def to_h
      result = {}
      instance_variables.each do |var|
        section = instance_variable_get(var)
        if section.respond_to? :data
          result.merge!(section.to_h) unless section.data.empty?
        end
      end
      result
    end

    def to_json
      MultiJson.dump(to_h, pretty: true)
    end

    def missing_keys
      missing = []
      unless type.nil?
        required_keys.each do |key|
          missing << key if @config[type][key].nil?
        end
      end
      missing
    end

    def self.type
      nil
    end
  end
end
