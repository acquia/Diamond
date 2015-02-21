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

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nemesis_ops/version'

Gem::Specification.new do |spec|
  spec.name          = 'nemesis_ops'
  spec.version       = NemesisOps::VERSION
  spec.authors       = ['Dan Norris']
  spec.email         = ['daniel.norris@acquia.com']
  spec.summary       = %q{Tools for managing Nemesis stacks}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ''
  spec.license       = 'Apache'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'fpm'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'librarian-puppet'
  spec.add_dependency 'oj'
  spec.add_dependency 'puppet'
  spec.add_dependency 'semantic'
  spec.add_dependency 'thor'
end
