require 'spec_helper'

describe 'acquia_registry', :type => :class do
  let(:facts) {
    {
      :registry_endpoint => 'registry.sandbox.acquia.io',
      :registry_storage_region => 'us-east-1',
      :registry_storage_bucket => 'some-bucket',
      :registry_ssl_certificate => 'somehash',
      :registry_ssl_key => 'someotherhash',
      :osfamily => 'redhat',
    }
  }

  it { should compile.with_all_deps }
  it { should contain_class('acquia_registry::common') }
  it { should contain_class('acquia_registry::client') }

  context 'includes docker-registry' do
    let(:facts) {
      super().merge({ :server_type => 'docker-registry' })
    }

    it { should contain_class('acquia_registry::server') }
  end
end
