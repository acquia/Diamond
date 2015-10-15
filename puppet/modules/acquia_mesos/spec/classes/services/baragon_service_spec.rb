require 'spec_helper'

describe 'acquia_mesos::services::baragon_service', :type => :class do
  let(:facts) {
    {
      :osfamily => 'redhat',
    }
  }

  it { should compile }

  it { should contain_acquia_mesos__services__baragon_service }

  it {
    should contain_file('/etc/baragon')
    should contain_file('/etc/baragon/baragon_service_config.yaml')
  }

  it {
    should contain_docker__run('baragon-service').with(
      {
        'image' => 'hubspot/baragonservice:latest',
      }
    )
  }
end
