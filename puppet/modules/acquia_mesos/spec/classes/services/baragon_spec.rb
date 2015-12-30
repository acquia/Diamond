require 'spec_helper'

describe 'acquia_mesos::services::baragon', :type => :class do
  let(:facts) {
    {
      :osfamily => 'redhat',
    }
  }

  it { should compile }

  it { should contain_acquia_mesos__services__baragon }

  context 'sets up baragon configuration files' do
    let(:facts) {
      super().merge(
        {
          :ec2_local_ipv4 => '10.0.0.1',
        }
      )
    }
    let(:params) {
      {
        :baragon_port => 6060,
      }
    }
    it {
      should contain_file('/etc/baragon')
      should contain_file('/etc/baragon/baragon.yaml')
        .with_content(/hostname: 10.0.0.1/)
        .with_content(/port: 6060/)
    }
  end

  context 'installs and runs the baragon docker container' do
    it {
      should contain_docker__image('acquia/baragon-master')
        .with_image_tag('latest')

      should contain_docker__run('baragon-master')
        .with_privileged(false)
        .with_image('acquia/baragon-master:latest')
    }
  end

  context 'pulls the baragon container from a remote registry' do
    let(:facts) {
      super().merge(
        {
          :private_docker_registry => 'registry.example.com/'
        }
      )
    }
    it {
      should contain_docker__run('baragon-master')
        .with_image('registry.example.com/acquia/baragon-master:latest')
    }
  end

  context 'pulls the correct version of the baragon container' do
    let(:params) {
      {
        :version => '1.0'
      }
    }
    it {
      should contain_docker__run('baragon-master')
        .with_image('acquia/baragon-master:1.0')
    }
  end
end
