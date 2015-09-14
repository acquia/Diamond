require 'spec_helper'

describe 'acquia_registry::common', :type => :class do
  let(:facts) {
    {
      :registry_endpoint => 'registry.sandbox.acquia.io',
      :registry_ssl_certificate => 'somehash',
      :operatingsystem => 'Ubuntu',
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
      :lsbdistid => 'Ubuntu',
    }
  }

  it { should compile }

  context 'creates all necessary directories' do
    it { should contain_file('/etc/docker') }
    it { should contain_file('/etc/docker/certs.d') }
    it { should contain_file("/etc/docker/certs.d/#{facts[:registry_endpoint]}") }
  end

  context 'creates the certificate file' do
    it {
      should contain_file("/etc/docker/certs.d/#{facts[:registry_endpoint]}/domain.crt")
        .with_ensure('present')
        .with_content(facts[:registry_ssl_certificate])
    }
  end
end
