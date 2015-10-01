require 'spec_helper'

describe 'acquia_mesos::master', :type => :class do
  it { should compile.with_all_deps }

  let(:facts) {
    {
      :aurora_zookeeper_connection_string => '10.0.0.1:2181,10.0.0.2:2181',
    }
  }

  let(:params) {
    {
      mesos_lib_dir: '/mnt/lib/mesos',
      mesos_log_dir: '/mnt/log/mesos',
    }
  }

  context 'configures a mesos master' do
    it {
      should contain_class('mesos::master').with_work_dir('/mnt/lib/mesos')
    }

    it {
      should contain_service('mesos-master').with(
        :enable => true
      )
    }

    context 'configures mesos options' do
      let(:mesos_quorum) { 5 }

      let(:facts) {
        {
          :mesos_quorum => mesos_quorum,
          :aurora_zookeeper_connection_string => '10.0.0.1:2181,10.0.0.2:2181',
        }
      }

      it {
        should contain_mesos__property('external_log_file').with_value('/mnt/log/mesos/mesos-master.INFO')
        should contain_mesos__property('log_auto_initialize').with_value(true)
        should contain_mesos__property('quorum').with_value(mesos_quorum)
        should contain_mesos__property('registry').with_value('replicated_log')
        should contain_mesos__property('registry_store_timeout').with_value('10secs')
        should contain_mesos__property('root_submissions').with_value(true)
        should contain_mesos__property('slave_removal_rate_limit').with_value('100/1mins')
      }
    end
  end
end
