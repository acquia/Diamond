require 'spec_helper'

describe 'acquia_mesos::services::dns::agent', :type => :class do
  let(:facts) {
    {
      :mesos_masters_private_ips => '127.0.0.3,127.0.0.4,127.0.0.5',
      :osfamily => 'redhat',
    }
  }

  it { should compile.with_all_deps }

  context 'configures dns for a mesos agent' do
    it {
      should contain_acquia_mesos__services__dns__agent
    }
  end

  context 'configures dnsmasq' do
    it {
      should contain_package('dnsmasq')

      should contain_service('dnsmasq')
        .with_ensure('running')

      should contain_dnsmasq__conf('mesos')
        .with_prio('10')
        .with_content(/server=127.0.0.3/)
        .with_content(/server=127.0.0.4/)
    }
  end

  context 'configures resolv.conf' do
    let(:facts) {
      super().merge(
        {
          :dns_ec2_internal_domain_name_servers => '10.0.0.5',
        }
      )
    }

    it {
      should contain_resolv_conf

      contain_file('resolv.conf')
        .with_content(/mesos/)
        .with_content(/10.0.0.5/)
    }
  end
end
