require 'spec_helper'

describe 'acquia_mesos::services::dns::master', :type => :class do
  let(:facts) {
    {
      :mesos_masters => '127.0.0.2,127.0.0.3,127.0.0.4',
      :mesos_zookeeper_connection_string => 'zk://10.0.1.112:2181,10.0.2.54:2181,10.0.0.133:2181',
      :osfamily => 'redhat',
    }
  }

  it { should compile.with_all_deps }

  context 'configures dns for a mesos master' do
    it {
      should contain_acquia_mesos__services__dns__master
    }
  end

  context 'configures mesos-dns' do
    context 'sets up configuration files' do
      let(:facts) {
        super().merge(
          {
            :dns_ec2_internal_domain_name_servers => '10.0.0.5',
          }
        )
      }

      it {
        should contain_file('/etc/mesos-dns/')
          .with_ensure('directory')

        should contain_file('/etc/mesos-dns/mesos-dns.json')
          .with_content(/"refreshSeconds": 60,/)
          .with_content(/10.0.0.5/)
      }
    end

    context 'installs and runs the mesos-dns docker container' do
      it {
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
end
