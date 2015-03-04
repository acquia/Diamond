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

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rubocop/rake_task'

# This is to get around https://github.com/rodjek/puppet-lint/issues/331
Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = ['puppet/third_party/**/*.pp']
  config.fail_on_warnings = true
  config.disable_checks = [
    '80chars',
    'class_inherits_from_params_class',
    'class_parameter_defaults',
    'documentation',
  ]
end

desc 'Run Rubocop on code we have written'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb', 'puppet/modules/**/*.rb']
  task.options = ['-D']
end

desc 'Run tests with code coverage'
task :rcoverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
