#!/usr/bin/env ruby
#
# Copyright 2015 Acquia, Inc.
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
#
#
# Build all packages and containers used within the nemesis-puppet manifests
#
# - Skip a package build
#    Place an empty 'skip' file in a package directory to skip building it
# - Environment variables
#    Add a env.conf in a package directory or your globally with NEMESIS_PUPPET_#{VAR}
#

require 'fileutils'
require 'optparse'
require 'yaml'

# Monkey patch to help convert build time result to a more readable format
class Numeric
  def duration
    rest, secs = self.divmod( 60 )
    rest, mins = rest.divmod( 60 )
    days, hours = rest.divmod( 24 )

    result = []
    result << "#{days} Days" if days > 0
    result << "#{hours} Hours" if hours > 0
    result << "#{mins} Minutes" if mins > 0
    result << "#{secs} Seconds" if secs > 0
    return result.join(' ')
  end
end

# Attempt to read the Github OAuth token from the global .gitconfig and make it
# available in ENV
if ENV['GITHUB_OAUTH_TOKEN'].nil? || ENV['GITHUB_OAUTH_TOKEN'] == ""
  github_oauth_token = `git config --global github.token`
  if github_oauth_token == ""
    puts 'Error: GITHUB_OAUTH_TOKEN environment variable not set'
    exit 1
  end
  ENV['GITHUB_OAUTH_TOKEN'] = github_oauth_token
end

basedir=File.expand_path(File.dirname(__FILE__))
$distdir=File.join(basedir, '..', 'dist', 'packages')

# Run through all listed container builds in a list and execute their build process.
def run_container_build(basedir, list, config, options)
  puts "Starting build for: containers" unless options[:list]
  list.each do |script|
    name = File.dirname(script)
    package_build_dir = File.join(basedir, name)
    next if ((config && config['skip']) || '').include?(name)

    if options[:list]
      puts "#{name}"
    else
      puts "Building: #{name}"
      Dir.chdir(package_build_dir) do
        case File.basename(script)
        when "Dockerfile"
          tag = 'latest'
          puts "docker build -t #{name}:#{tag} ."
          system("docker build -t #{name}:#{tag} .")
        when "build.sh"
          system("/bin/bash build.sh")
        when "Makefile"
          system("make && make clean")
        end
      end
    end
  end
end

# Package builds are split into two parts, first a Dockerfile which sets up all the dependencies for
# building that package and second a package.sh script with is the command entrypoint for the container.
# This pattern allows for packages to be recreated and developed easier, but requires a two part build/run
# for the resulting package to be created.
def run_package_build(basedir, list, config, options)
  puts "Starting build for: packages" unless options[:list]
  list.each do |script|
    name = File.dirname(script)
    package_build_dir = File.join(basedir, name)
    next if ((config && config['skip']) || '').include?(name)

    if options[:list]
      puts "#{name}"
    else
      env_file = File.join(package_build_dir, 'env.conf')
      puts "Building: #{name}"
      Dir.chdir(package_build_dir) do
        case File.basename(script)
        when "Dockerfile"
          tag = 'latest'
          system("docker build -t #{name}:latest .")
          # Add custom env flags
          flags = []
          flags << " -e 'GITHUB_OAUTH_TOKEN=#{ENV['GITHUB_OAUTH_TOKEN']}'" if ENV['GITHUB_OAUTH_TOKEN']
          flags << " --env-file #{env_file}" if File.exist?(env_file)
          global_env_flags = ENV.select { |k, v| k =~ /^NEMESIS_PUPPET/}.map { |k, v| " -e '#{k}=#{v}'" }
          flags.concat(global_env_flags) if global_env_flags

          # Check the package volume mount type
          package_visability = (config['public'] || '').include?(name) ? 'public' : 'private'
          dist_volume_mount = File.join($distdir, package_visability)

          # Run the container
          unless system("docker run -i --rm #{flags.join(' ')} -v #{dist_volume_mount}:/dist #{name}:#{tag}")
            puts "Error: #{name}:#{tag} build exited with code #{exit_code}"
            exit 1
          else
            system("docker rmi -f #{name}:#{tag}")
          end
        when "build.sh"
          system("/bin/bash build.sh")
        when "Makefile"
          system("make")
        end
      end
    end
  end
end

# Map of build directories to build type
build_directories={
  'bootstrap' => 'container',
  'packages' => 'package',
  'containers' => 'container',
}

build_list=[]
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: build.sh [OPTIONS] REGEX_PATTERN"
  opts.on('-b', 'Build Bootstrap Containers') { build_list=['bootstrap'] }
  opts.on('-c', 'Build Containers') { build_list=['containers'] }
  opts.on('-p', 'Build Packages') { build_list=['packages'] }
  opts.on('-d', '--dist DIR', String) { |v| $distdir = v }
  opts.on('-l', '--list') { options[:list] = true }
end.parse!

build_list = build_directories.keys if build_list.empty?

regex_pattern = ARGV[0] || '**'

# Load build config
build_config = YAML.load_file(File.join(basedir, 'config.yaml'))

FileUtils.mkdir_p([File.join($distdir, 'private'), File.join($distdir, 'public')])
start_time = Time.now
# Change to where the build script is since there are hardcoded paths and assumptions for the build
Dir.chdir(basedir) do
  # Loop through the build directiries
  build_list.sort.each do |build_dir|
    # Change into the specific build directory and search for any files matching the regex_pattern to be built
    Dir.chdir(build_dir) do
      files = Dir.glob("#{regex_pattern}/{Dockerfile,Makefile,build.sh}")
      path = File.join(basedir, build_dir)
      config = build_config[build_dir]
      send("run_#{build_directories[build_dir]}_build", path, files, config, options) unless files.size == 0
    end
  end
end

build_time = Time.now - start_time
puts "Build Time: #{build_time.duration}" unless options[:list]

if `docker ps -a | grep Exited | wc -l`.to_i > 0
  system("docker rm $(docker ps -a | grep Exited | awk '{print $1}')")
end

