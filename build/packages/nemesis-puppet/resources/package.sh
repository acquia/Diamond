#!/usr/bin/env ruby

require 'date'
require 'fileutils'
require 'logger'
require 'optparse'
require 'pathname'
require 'tempfile'

is_release = (ENV['NEMESIS_PUPPET_RELEASE'].nil? || ENV['NEMESIS_PUPPET_RELEASE'].empty?) ? false : true

options = {
  :release => is_release,
  :repo => ENV['NEMESIS_PUPPET_REPO']  || 'acquia/nemesis-puppet',
  :branch => ENV['NEMESIS_PUPPET_BRANCH'] || 'master',
  :github_oauth_token => ENV['GITHUB_OAUTH_TOKEN'],
  :basedir => ENV['NEMESIS_PUPPET_SOURCE_DIR'] || '/nemesis-puppet',
  :distdir => ENV['PACKAGE_DIST_DIR'] || '/dist',
}

OptionParser.new do |opt|
  opt.on('--[no-]release', 'Perform release build') { |o| options[:release] = o }
  opt.on('--dir PATH', 'Base directory containing nemesis-puppet checkout') { |o| options[:basedir] = o }
  opt.on('--dist PATH', 'Dist directory to place build packages') { |o| options[:distdir] = o }

  opt.on('-r', '--repo URL', 'Git repository URL') { |o| options[:repo] = o }
  opt.on('-b', '--branch BRANCH_NAME', 'Git repository branch') { |o| options[:branch] = o }
end.parse!

@log = Logger.new($stdout)
@log.level = Logger::INFO
@log.formatter = proc do |severity, datetime, progname, msg|
  format("[%s] %s%s\n",
    datetime.strftime('%Y-%m-%d %H:%M:%S'),
    severity == 'INFO' ? '' : "#{severity}: ",
    msg
  )
end

# Taken from semantic, source available at
#   - https://github.com/jlindsey/semantic/master/lib/semantic/version.rb
#
# This is necessary due to a bug caused by puppet embedding an older version of
# semantic and the way that puppet autoloads it resulting in
#
#   Error: Could not parse application options: uninitialized constant Semantic::Dependency
#
class Version
  SemVerRegexp = /\A(\d+\.\d+\.\d+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?\Z/
  attr_accessor :major, :minor, :patch, :pre, :build

  def initialize version_str
    raise ArgumentError.new("#{version_str} is not a valid SemVer Version (http://semver.org)") unless version_str =~ SemVerRegexp

    version, parts = version_str.split '-'
    if not parts.nil? and parts.include? '+'
      @pre, @build = parts.split '+'
    elsif version.include? '+'
      version, @build = version.split '+'
    else
      @pre = parts
    end

    @major, @minor, @patch = version.split('.').map(&:to_i)
  end

  def build=(b)
    @build = (!b.nil? && b.empty?) ? nil : b
  end

  def to_a
    [@major, @minor, @patch, @pre, @build]
  end

  def to_s
    str = [@major, @minor, @patch].join '.'
    str << '-' << @pre unless @pre.nil?
    str << '+' << @build unless @build.nil?

    str
  end

  def to_h
    keys = [:major, :minor, :patch, :pre, :build]
    Hash[keys.zip(self.to_a)]
  end

  alias to_hash to_h
  alias to_array to_a
  alias to_string to_s

  [:major, :minor, :patch].each do |term|
    define_method("#{term}!") { increment!(term) }
  end

  def increment!(term)
    new_version = clone
    new_value = send(term) + 1

    new_version.send("#{term}=", new_value)
    new_version.minor = 0 if term == :major
    new_version.patch = 0 if term == :major || term == :minor
    new_version.build = new_version.pre = nil

    new_version
  end
end

# Build a .rpm package containing all of the Puppet modules in the project
#
# @param builddir [string] - path to nemesis-puppet
# @param distdir [string] - path to output packages
# @param version [string] - version string, must be semver
def build(builddir, distdir, version, build_time)
  @log.info("Bumping version to #{version}")

  @log.info("Installing dependencies")
  unless system('bundle install')
    @log.error('Error installing dependencies')
    exit 1
  end

  @log.info('Updating puppet 3rd party modules')
  unless system('librarian-puppet install')
    @log.error('Error installing puppet 3rd party modules')
    exit 1
  end

  Dir.mktmpdir do |dir|
    # Copy over third party and puppet modules
    @log.info('Preparing to build nemesis-puppet package')
    FileUtils.cp_r(builddir.join('puppet'), dir)
    librar_puppet_files = Pathname.new(ENV['LIBRARIAN_PUPPET_PATH'])
    files = Dir.glob("#{librar_puppet_files}*")
    dest = File.join(dir, 'puppet', 'modules')
    FileUtils.mv(files, dest, verbose: false, force: true)

    @log.info('Building nemesis-puppet package')
    cli = 'fpm' \
      ' --force' \
      " -C #{dir + '/puppet'}" \
      ' -s dir' \
      ' -t rpm' \
      ' -n nemesis-puppet'\
      " -v #{version}" \
      " -p #{distdir}" \
      " --vendor 'Acquia, Inc.'" \
      ' --depends puppet' \
      " -m 'engineering@acquia.com'" \
      " --description \"Acquia #{version} built on #{build_time}\" " \
      ' --prefix /etc/puppet' \
      ' .'

    @log.info(cli)
    FileUtils.mkdir_p(distdir)
    system("#{cli}")
  end
end

# Get a package version to apply to this nemesis-puppet build
#
# @param stack_name [String] name of the stack
# @param build_time [DateTime] the time to apply to the build
# @param release [Boolean] whether or not this is a release build
# @return [String] the version to apply to the package
def package_version(build_time, release = false)
  version = Version.new(`git describe --abbrev=0 --tags`.strip)
  unless release
    version = Version.new("#{version}+#{build_time.strftime('%s')}")
  end
  version
end

basedir = Pathname.new(options[:basedir])
distdir = Pathname.new(options[:distdir])
builddir = Pathname.new('/tmp/nemesis-puppet')

if File.exist?(builddir)
  @log.info('removing existing copy of #{builddir}')
  FileUtils.rm_rf(builddir)
end
FileUtils.mkdir_p(builddir)

# Error Checks
# Do not allow releases to be built off master
if options[:release] == true && options[:branch] == 'master'
  @log.error('Releases can not be built off master branch. Please set NEMESIS_PUPPET_BRANCH to a specific tag')
  exit 1
end

# Clone the repo from github is performing a release, otherwise use the local /nemesis-puppet mount to clone from
if options[:release]
  @log.error("GITHUB_OAUTH_TOKEN environment variable is not set") unless options[:github_oauth_token]
  cmd = "git clone -b #{options[:branch]} https://#{options[:github_oauth_token]}:x-oauth-basic@github.com/#{options[:repo]}.git #{builddir}"
  @log.info("Cloning down #{options[:repo]}:#{options[:branch]} to #{builddir}")
  unless system(cmd)
    @log.error("Error cloning #{options[:repo]}:#{options[:branch]} to #{builddir}")
    @log.error("#{cmd}")
    exit 1
  end
else
  @log.info("Copying source from #{basedir} to #{builddir}")
  # exclude dist content from the copy
  unless system("/usr/bin/rsync -a --exclude=.tmp --exclude=dist #{basedir}/ #{builddir}")
    @log.error("Error copying #{basedir} to #{builddir}")
    exit 1
  end
end

Dir.chdir(builddir) do
  build_time = DateTime.now
  version = package_version(build_time, options[:release])
  build(builddir, distdir, version, build_time)
end
