require 'spec_helper'

describe 'acquia_mesos::aurora::scheduler', :type => :class do
  it { should compile.with_all_deps }

  let(:facts) {
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7',
    }
  }

  context 'configures a mesos master with the aurora scheduler' do
    it {
      should contain_class('acquia_mesos::aurora::scheduler')
      should contain_package('aurora-scheduler')
      should contain_package('aurora-tools')

      should contain_service('aurora-scheduler')

      should contain_user('aurora')
      should contain_group('aurora')

      should contain_file('/etc/aurora').with_ensure('directory')
      should contain_file('/etc/sysconfig/aurora-scheduler')
      should contain_file('/etc/aurora/clusters.json')

      should contain_file('/var/lib/aurora').with_ensure('directory')
      should contain_file('/var/lib/aurora/scheduler').with_ensure('directory')
      should contain_file('/var/lib/aurora/scheduler/db').with_ensure('directory')

      should contain_exec('init-mesos-log')
      should contain_exec('set_aurora_home_perms')
    }
  end
end
