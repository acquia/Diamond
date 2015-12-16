require 'spec_helper'

describe 'acquia_base::diamond' do
  let(:facts) do |_|
    {
      osfamily: 'RedHat',
    }
  end

  context 'installs necessary packages' do
    it {
      should contain_class('acquia_base::diamond')
      should contain_class('python')
        .with_pip(true)

      should contain_group('diamond')
      should contain_group('docker')

      should contain_user('diamond')
        .with_groups(['diamond', 'docker'])

      should contain_package('diamond')
      should contain_package('diamond')
      should contain_python__pip('docker-py')
    }
  end

  context 'creates all necessary files and directories' do
    it {
      should contain_file('/mnt/log/diamond')
        .with_ensure('directory')

      should contain_file('/etc/diamond/handlers')
        .with_ensure('directory')

      should contain_file('/etc/diamond/collectors')
        .with_ensure('directory')

      should contain_file('/etc/diamond/diamond.conf')
    }
  end

  context 'configures diamond with necessary custom handlers' do
    let(:facts) {
      super().merge(
        {
          :server_type => 'mesos',
          :mesos_master => true
        }
      )
    }
    it {
      should contain_file('/etc/diamond/diamond.conf')
        .with_content(/MesosCollector/)
        .with_content(/port = 5050/)
    }
  end

  context 'starts diamond service' do
    it {
      should contain_service('diamond')
        .with_ensure('running')
    }
  end
end
