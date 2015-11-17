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
require 'rake/clean'

task :test => :spec
task :all => [:validate, :lint, :style, :rcoverage]

task(:default).clear
task :default => :all

# List of extra files to delete when rake clean is run
CLEAN.include("coverage")
CLOBBER.include("dist")

# This is to get around https://github.com/rodjek/puppet-lint/issues/331
Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = [
    'puppet/third_party/**/*.pp',
    'puppet/**/spec/fixtures/modules/**/*.pp'
  ]
  config.fail_on_warnings = true
  config.disable_checks = [
    '80chars',
    'class_inherits_from_params_class',
    'class_parameter_defaults',
    'only_variable_string',
    'documentation',
    'variable_scope',
  ]
end

Rake::Task[:spec].clear
task :spec do
  Rake::Task['spec_modules'].invoke
end

desc 'Run all modules/* rake tasks'
task :spec_modules do
  modules = Dir.glob('puppet/modules/*')
  modules.each do |mod|
    next unless File.exists?("#{mod}/Rakefile")
    puts "Running rake for #{mod}"
    Dir.chdir(mod) do
      sh 'rake'
    end
  end
end

task :clean do
  Rake::Cleaner.cleanup_files(CLEAN)
  Rake::Task['spec_clean'].execute

  modules = Dir.glob('puppet/modules/*')
  modules.each do |mod|
    next unless File.exists?("#{mod}/Rakefile")
    puts "Running rake clean for #{mod}"
    Dir.chdir(mod) do
      sh 'rake clean'
      sh 'rake spec_clean'
    end
  end
end


task :style => [:'style:rubocop']
namespace :style do
  desc 'Run rubocop style tests'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = [
      'lib/**/*.rb',
      'puppet/modules/**/*.rb',
      'puppet/lib/**/*.rb',
    ]
    task.options = ['-D', '--force-exclusion', '-c', "#{File.expand_path(File.dirname(__FILE__))}/.rubocop.yml"]
  end
end

desc 'Run tests with code coverage'
task :rcoverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
