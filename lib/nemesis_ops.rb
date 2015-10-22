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
require 'pathname'
require 'require_all'

module NemesisOps
  GPG_KEY = '23406CA7'
  DEFAULT_OS = 'trusty'
  DEFAULT_AMI = 'ami-f63b3e9e' # 64-bit hvm
  DEFAULT_INSTANCE_TYPE = 'm3.medium'
  AWS_TOOLS_VERSION = '1.5.6'

  BASE_PATH = Pathname.new(File.dirname(File.dirname(File.absolute_path(__FILE__))))
  BUILD_DIR = BASE_PATH.join('build')
  PKG_DIR = BUILD_DIR.join('packages')
  DIST_DIR = BASE_PATH.join('dist')
  PKG_CACHE_DIR = DIST_DIR.join('cache')
  PKG_REPO_DIR = DIST_DIR.join('repo')

  # List of file patterns to always exclude from S3 syncs
  EXCLUDE_PATTERNS = [
    /\.s[a-w][a-z]$/, # vim swap files
  ]

  # Generate an autoload statement by creating an appropriate symbol and path
  # :nocov:
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

  require_all "#{File.dirname(__FILE__)}/nemesis_ops/packer_gen"
end
