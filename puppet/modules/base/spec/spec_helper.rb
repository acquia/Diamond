require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet'

RSpec.configure do |c|
  c.color = true
  c.full_backtrace = true
  c.raise_errors_for_deprecations!
  c.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera/hiera.yaml'))

  c.before :each do
    # Ensure that we don't accidentally cache facts and environment between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key { |k| @old_env[k] = ENV[k] }

    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables] = true
    end
  end
  c.after :each do
    PuppetlabsSpec::Files.cleanup
  end
end
