require 'spec_helper'

describe 'acquia_mesos::services::mesos_dns', :type => :class do
  let(:facts) {
    {
      :mesos_masters => '127.0.0.2,127.0.0.3,127.0.0.4',
      :mesos_masters_private_ips => '127.0.0.2,127.0.0.3,127.0.0.4',
      :mesos_zookeeper_connection_string => 'zk://10.0.1.112:2181,10.0.2.54:2181,10.0.0.133:2181/mesos',
      :osfamily => 'redhat',
    }
  }

  it { should compile.with_all_deps }
  it { should contain_acquia_mesos__services__mesos_dns }

  context 'pulls and runs the mesos-dns container' do
    it {
      should contain_file('/etc/mesos-dns')
      should contain_file('/etc/mesos-dns/mesos-dns.json')

      should contain_docker__image('acquia/mesos-dns')
        .with_image_tag('latest')

      should contain_docker__run('mesos-dns')
        .with_privileged(false)
        .with_image('acquia/mesos-dns:latest')
    }
  end

  context 'pulls the mesos-dns container from a remote registry' do
    let(:facts) {
      super().merge(
        {
          :private_docker_registry => 'registry.example.com/'
        }
      )
    }
    it {
      should contain_docker__run('mesos-dns')
        .with_image('registry.example.com/acquia/mesos-dns:latest')
    }
  end

  context 'pulls the correct version of the mesos-dns container' do
    let(:params) {
      {
        :version => '1.0'
      }
    }
    it {
      should contain_docker__run('mesos-dns')
        .with_image('acquia/mesos-dns:1.0')
    }
  end
end
