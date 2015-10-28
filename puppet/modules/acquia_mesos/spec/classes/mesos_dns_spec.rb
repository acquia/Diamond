require 'spec_helper'

describe 'acquia_mesos::mesos_dns', :type => :class do
  let(:facts) {
    {
      :mesos_masters => '127.0.0.2,127.0.0.3,127.0.0.4',
      :mesos_masters_private_ips => '127.0.0.2,127.0.0.3,127.0.0.4',
      :mesos_zookeeper_connection_string => 'zk://10.0.1.112:2181,10.0.2.54:2181,10.0.0.133:2181/mesos',
      :operatingsystem => 'Ubuntu',
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
      :lsbdistid => 'Ubuntu',
    }
  }

  it { should compile.with_all_deps }

  # The next line makes no sense, but is apparently needed to make
  # RSpec::Puppet recognize that acquia_mesos::mesos_dns is
  # "covered" by specs.
  it { should contain_acquia_mesos__mesos_dns }

  context 'installs and runs the mesos-dns Docker container' do
    it {
      should contain_file('/etc/mesos-dns')
      should contain_file('/etc/mesos-dns/mesos-dns.json')
      should contain_docker__run('mesos-dns').with_privileged(false).with_image('acquia/mesos-dns:latest')
    }
  end

  context 'pulls mesos-dns from the registry endpoint with a specific version' do
    let(:facts) {
      super().merge(:registry_endpoint => 'myregistry.example.com')
    }
    let(:params) {
      {
        :mesos_dns_version => '99.2.1',
      }
    }
    it {
      should contain_docker__run('mesos-dns').with_privileged(false).with_image('myregistry.example.com/acquia/mesos-dns:99.2.1')
    }
  end
end
