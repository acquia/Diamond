require 'spec_helper'

describe 'acquia_mesos::aurora::executor', :type => :class do
  let(:facts) {
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7',
    }
  }

  it { should compile.with_all_deps }

  context 'configures a mesos agent with aurora executor' do
    it {
      should contain_class('acquia_mesos::aurora::executor')
      should contain_package('aurora-executor')
      should contain_service('thermos')

      should contain_file('/etc/sysconfig/thermos')
    }
  end
end
