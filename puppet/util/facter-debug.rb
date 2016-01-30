#!/usr/bin/env ruby

# Construct the path to all the Facter libraries and plugins, then run
# Facter.
#
# Intended to be used while debugging Facter in place on running
# instances.

# Set the AWS_REGION unless one is provided
unless ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION']
  zone = `curl 169.254.169.254/2014-11-05/meta-data/placement/availability-zone 2>/dev/null`
  ENV['AWS_REGION'] = $1 if zone =~ /\A(.*?)[a-z]\z/
end

# Make sure /etc/puppet/lib is in the Ruby load path
rubylib_parts = ENV['RUBYLIB'] ? ENV['RUBYLIB'].split(':') : []
unless rubylib_parts.include?('/etc/puppet/lib')
  ENV['RUBYLIB'] = rubylib_parts.unshift('/etc/puppet/lib').join(':')
end

# TODO: The third-party Jenkins plugin gives an error when included in
# FACTERLIB this way, so I'm just rejecting third-party plugins for
# now. Someone else should figure this out when we start seeing bugs
# in third-party facts.
facter_libs = Dir.glob("/etc/puppet/modules/**/lib/facter").reject { |x| x =~ /\/third_party\// }.sort
if ARGV[0] == 'list'
  # List all the Nemesis facter libs
  puts facter_libs.join("\n")

elsif ARGV[0] == 'testlib' && ARGV[1]
  # Run Facter with a specific Nemesis facter lib from the list.
  # You can specify an index in the output of `list`, or a lib path.
  whichlib = ARGV[1]
  if whichlib =~ /\A\d+\z/
    ENV['FACTERLIB'] = facter_libs[whichlib.to_i]
  else
    ENV['FACTERLIB'] = whichlib
  end
  puts "Testing Facter lib: #{ENV['FACTERLIB']}"
  puts `facter --puppet`

elsif ARGV[0] == 'run'
  # Put all the Puppet library directories into FACTERLIB, then run Facter
  ENV['FACTERLIB'] = facter_libs.join(':')
  puts `facter --puppet`

else
  puts "Usage: facter-debug.rb [run|list|testlib]"
end
