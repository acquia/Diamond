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
require 'fileutils'
require 'optparse'

# Attempt to read the Github OAuth token from the global .gitconfig
github_oauth_token=`git config --global github.token` || ENV['GITHUB_OAUTH_TOKEN']

unless github_oauth_token
 puts 'Error: GITHUB_OAUTH_TOKEN environment variable not set'
 exit 1
else
  ENV['GITHUB_OAUTH_TOKEN'] = github_oauth_token
end

$basedir=File.expand_path(File.dirname(__FILE__))
$distdir=File.join($basedir, '..', 'dist')

# Run through all listed container builds in a list and execute their build process.
def run_containers_build(list)
  puts "Starting build for: containers"
  list.each do |script|
    name = File.dirname(script)
    package_build_dir = File.join($basedir, 'containers', name)
    next if File.exist?(File.join(package_build_dir, 'skip'))
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
        system("make")
      end
    end
  end
end

# Package builds are split into two parts, first a Dockerfile which sets up all the dependencies for
# building that package and second a package.sh script with is the command entrypoint for the container.
# This pattern allows for packages to be recreated and developed easier, but requires a two part build/run
# for the resulting package to be created.
def run_packages_build(list)
  puts "Starting build for: packages"
  list.each do |script|
    name = File.dirname(script)
    package_build_dir = File.join($basedir, 'packages', name)
    next if File.exist?(File.join(package_build_dir, 'skip'))
    puts "Building: #{name}"
    Dir.chdir(package_build_dir) do
      case File.basename(script)
      when "Dockerfile"
        tag = 'latest'
        system("docker build -t #{name}:latest .")
        container_id=`docker run -d -e "GITHUB_OAUTH_TOKEN=#{ENV['GITHUB_OAUTH_TOKEN']}" -v #{$distdir}:/dist #{name}:#{tag}`
        exit_code=`docker wait #{container_id}`.to_i
        system("docker rm -f #{container_id}")

        if exit_code != 0
          puts "Error: #{name}:#{tag} build exited with code #{exit_code}"
          exit 1
        end
      when "build.sh"
        system("/bin/bash build.sh")
      when "Makefile"
        system("make")
      end
    end
  end
end


build_directories=['packages', 'containers']
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: build.sh [OPTIONS] REGEX_PATTERN"
  opts.on('-c', 'Build Containers') { build_directories=['containers'] }
  opts.on('-p', 'Build Packages') { build_directories=['packages'] }
  opts.on('-d', '--dist DIR', String) { |v| $distdir = v }
end.parse!


regex_pattern = ARGV[0] || '**'

FileUtils.mkdir_p($distdir)

# Change to where the build script is since there are hardcoded paths and assumptions for the build
Dir.chdir($basedir) do
  # Loop through the build directiries
  build_directories.each do |build_dir|
    # Change into the specific build directory and search for any files matching the regex_pattern to be built
    Dir.chdir(build_dir) do
      # The acquia directory is reserved for common base images used by all other builds.
      # Build those first and then run the build for everything else
      files = Dir.glob("acquia/#{regex_pattern}/{Dockerfile,Makefile,build.sh}")
      send("run_#{build_dir}_build", files) unless files.size == 0
      # now build everything else excluding the acquia directory
      files = Dir.glob("#{regex_pattern}/{Dockerfile,Makefile,build.sh}").reject{ |f| f =~ /acquia/ }
      send("run_#{build_dir}_build", files) unless files.size == 0
    end
  end
end

if `docker ps -a | grep Exited | wc -l`.to_i > 0
  system("docker rm $(docker ps -a | grep Exited | awk '{print $1}')")
end