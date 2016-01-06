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
  github_oauth_token = `git config --global github.token`.strip
  if github_oauth_token == ""
    puts 'Error: GITHUB_OAUTH_TOKEN environment variable not set'
    exit 1
  end
  ENV['GITHUB_OAUTH_TOKEN'] = github_oauth_token
end

# Defaults
basedir=File.expand_path(File.dirname(__FILE__))
$nemesis_puppet_root=File.join(basedir, '..')
$distdir=File.join($nemesis_puppet_root, 'dist')

$default_container = 'centos:7'
$volumes_container_name = 'nemesis-puppet-volumes'


# Initialized the dist folder and a volume container for other container builds
# to mount and use via the --volumes-from
# If there is no dist container running then pull the latest centos version
# and create a dist container
def init_volumes_container
  FileUtils.mkdir_p($distdir)

  unless system("docker ps -a --filter='name=#{$volumes_container_name}' | grep '#{$volumes_container_name}' 1>/dev/null")
    puts "Downloading the latest version of #{$default_container}"
    system("docker pull #{$default_container}")
    puts "Creating volumes container: #{$volumes_container_name}"
    system("docker create -v #{$nemesis_puppet_root}:/nemesis-puppet:ro -v #{$distdir}:/dist --name #{$volumes_container_name} #{$default_container} /bin/true")
  end
end

# Run the given container and when finished remove it
def run_container_build(name, tag, package_build_dir, global_env_vars)
  env_file = File.join(package_build_dir, 'env.conf')
  global_env_vars = global_env_vars.map { |k, v| " -e '#{k}=#{v}'" }

  flags = []
  flags.concat(global_env_vars) if global_env_vars
  flags << " --env-file #{env_file}" if File.exist?(env_file)

  # Run the container
  puts "Running build container: #{name}:#{tag}"
  unless system("docker run -i --rm #{flags.join(' ')} --volumes-from #{$volumes_container_name} #{name}:#{tag}")
    puts "Error: unable to run #{name}:#{tag}"
    exit 1
  else
    puts "Deleting build container: #{name}:#{tag}"
    system("docker rmi -f #{name}:#{tag}")
  end
end

# Run through all builds in a list and execute their script process.
def build(build_dir, basedir, list, config, options)
  puts "Starting build for: #{build_dir}" unless options[:list]
  env_vars = {
    'PACKAGE_DIST_DIR' => '/dist/packages'
  }
  env_vars['GITHUB_OAUTH_TOKEN'] = ENV['GITHUB_OAUTH_TOKEN'] if ENV['GITHUB_OAUTH_TOKEN']
  global_env_flags = ENV.select { |k, v| k =~ /^NEMESIS/}.each { |k, v| env_vars[k] = v }

  list.uniq.each do |package_config_file|
    name = File.dirname(package_config_file)
    package_build_dir = File.join(basedir, name)
    build_config = YAML.load_file(package_config_file)

    unless build_config['output']
      build_config['output'] = [name]
    end

    next if ((config && config['skip']) || build_config['skip'] || '').include?(name)

    if options[:list]
      build_config['output'].each { |x| puts x }
    else
      puts "Building: #{name}"
      Dir.chdir(package_build_dir) do
        case build_config['script']
        when 'Dockerfile'
          tag = 'latest'
          system("docker build --no-cache -t #{name}:#{tag} .")

          # Package builds are split into two parts, first a Dockerfile which sets up all the dependencies for
          # building that package and second a package.sh script with is the command entrypoint for the container.
          # This pattern allows for packages to be recreated and developed easier, but requires a two part build/run
          # for the resulting package to be created.
          if build_dir == 'packages'
            FileUtils.mkdir_p(File.join($distdir, 'packages'))
            run_container_build(name, tag, package_build_dir, env_vars)
          end
        when 'build.sh'
          system(env_vars, "/bin/bash build.sh")
        when 'Makefile'
          system(env_vars, "make")
        end
      end
    end
  end
end

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

build_list = ['bootstrap', 'containers', 'packages'] if build_list.empty?

regex_pattern = ARGV[0] || '**'

# Load build config
build_config = YAML.load_file(File.join(basedir, 'config.yaml'))

# Initialize the volumes container for dist and nemesis-puppet root
init_volumes_container

start_time = Time.now
# Change to where the build script is since there are hardcoded paths and assumptions for the build
Dir.chdir(basedir) do
  # Loop through the build directiries
  build_list.sort.each do |build_dir|
    # Change into the specific build directory and search for any files matching the regex_pattern to be built
    Dir.chdir(build_dir) do
      files = Dir.glob("#{regex_pattern}/build.yaml")
      path = File.join(basedir, build_dir)
      config = build_config[build_dir]
      build(build_dir, path, files, config, options) unless files.size == 0
    end
  end
end

build_time = Time.now - start_time
puts "Build Time: #{build_time.duration}" unless options[:list]

# Purge any exited containers that have been left hanging around
if ENV['DOCKER_HOST'] || File.exists?('/var/run/docker.sock')
  exited_containers = `docker ps -a | grep Exited | wc -l`.to_i
  if exited_containers > 0
    puts "Cleaning up #{exited_containers} exited containers"
    system("docker rm $(docker ps -a | grep Exited | awk '{print $1}')")
  end
end
