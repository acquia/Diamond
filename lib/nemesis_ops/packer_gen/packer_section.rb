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

require 'forwardable'

module NemesisOps::PackerGen
  class PackerSection
    extend Forwardable
    def_delegators :@data, :[], :[]=

    attr_reader :key, :data
    def initialize(key)
      @key = key
      @data = {}
      @ordering_key = 0
    end

    def add(data)
      @data[@ordering_key] = data
      @ordering_key += 1
    end

    def data_to_arr
      @data.map { |_, value| value }
    end

    def to_h
      { @key => data_to_arr }
    end
  end
end
