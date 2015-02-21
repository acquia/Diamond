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

require 'nemesis_ops/version'

module NemesisOps
  GPG_KEY = '23406CA7'
  DEFAULT_OS = 'trusty'

  BASE_PATH = Pathname.new(File.dirname(File.dirname(File.absolute_path(__FILE__))))
  PKG_DIR = BASE_PATH.join('packages')

  # List of file patterns to always exclude from S3 syncs
  EXCLUDE_PATTERNS = [
    /\.s[a-w][a-z]$/, # vim swap files
  ]

  # Generate an autoload statement by creating an appropriate symbol and path
  def self.autoload_file(file)
    sym = nil
    file = File.basename(file, File.extname(file))
    if file.include? '_'
      sym = file.split('_').map(&:capitalize).join.to_sym
    else
      sym = file.capitalize.to_sym
    end
    autoload sym, "nemesis_ops/#{file}"
  end

  # Autoload everything in the lib/nemesis folder automatically
  Dir.glob("#{File.absolute_path(File.dirname(__FILE__))}/nemesis_ops/*.rb").each do |f|
    NemesisOps.autoload_file f
  end
end
