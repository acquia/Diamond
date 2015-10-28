require 'spec_helper'

describe 'acquia_mesos::mesos_dns_client', :type => :class do
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
  # RSpec::Puppet recognize that acquia_mesos::mesos_dns_client is
  # "covered" by specs.
  it { should contain_acquia_mesos__mesos_dns_client }

  context 'installs pointers to mesos-dns into resolv.conf' do
    it { should contain_file('/etc/resolvconf/resolv.conf.d/head') }
    it { should contain_exec('resolvconf') }
  end
end
