require 'spec_helper'

describe 'acquia_registry::server', :type => :class do
  let(:facts) {
    {
      :registry_endpoint => 'registry.sandbox.acquia.io',
      :registry_ssl_key => 'someotherhash',
      :osfamily => 'redhat',
      :server_type => 'docker-registry'
    }
  }

  it { should compile }

  context 'docker registry server' do
    context 'creates an htpasswd file' do
      it { should contain_package('httpd-tools').with_ensure('present') }

      it {
        should contain_exec('create-htpasswd')
          .with_creates("/etc/docker/certs.d/#{facts[:registry_endpoint]}/htpasswd")
      }
    end

    context 'configures a docker registry' do
      it {
        should contain_file("/etc/docker/certs.d/#{facts[:registry_endpoint]}/domain.key")
          .with_ensure('present')
          .with_content(facts[:registry_ssl_key])
      }

      it {
        should contain_file("/etc/docker/certs.d/#{facts[:registry_endpoint]}/domain.cert")
          .with_ensure('link')
          .with_target("/etc/docker/certs.d/#{facts[:registry_endpoint]}/domain.crt")
      }
    end

    context 'starts a docker registry' do
       it {
        should contain_docker__run('registry').with(
          {
            'image' => 'registry:2.2.0',
          }
        )
      }
    end
  end
end
