require 'spec_helper'

describe 'acquia_registry::client', :type => :class do
  let(:facts) {
    {
      :registry_endpoint => 'registry.sandbox.acquia.io',
    }
  }

  it { should compile }

  context 'logs in to the registry on the server' do
    it {
      should contain_docker__registry(facts[:registry_endpoint])
        .with_username('admin')
    }
  end
end
