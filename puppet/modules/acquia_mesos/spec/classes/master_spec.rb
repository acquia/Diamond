require 'spec_helper'

describe 'acquia_mesos::master', :type => :class do
  it { should compile.with_all_deps }

  let(:facts) {
    {
      :aurora_zookeeper_connection_string => '10.0.0.1:2181,10.0.0.2:2181',
      :mesos_masters => '127.0.0.2,127.0.0.3,127.0.0.4',
      :mesos_masters_private_ips => '127.0.0.3,127.0.0.4,127.0.0.5',
      :mesos_zookeeper_connection_string => 'zk://10.0.1.112:2181,10.0.2.54:2181,10.0.0.133:2181',
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7',
    }
  }

  let(:params) {
    {
      :mesos_work_dir => '/mnt/lib/mesos',
      :mesos_log_dir => '/mnt/log/mesos',
    }
  }

  context 'configures a mesos master' do
    it {
      should contain_class('mesos::master').with_work_dir('/mnt/lib/mesos')
    }

    it {
      should contain_service('mesos-master').with_enable(true)
      should contain_service('mesos-slave').with_enable(false)
    }

    context 'configures mesos master properties' do
      let(:mesos_quorum) { 5 }

      let(:facts) {
        super().merge(
          {
            :mesos_quorum => mesos_quorum,
            :ec2_public_ipv4 => '12.34.56.78',
          }
        )
      }

      it {
        should contain_mesos__property('master_hostname').with_value('12.34.56.78')
        should contain_mesos__property('master_external_log_file').with_value('/mnt/log/mesos/mesos-master.INFO')
        should contain_mesos__property('master_log_auto_initialize').with_value(true)
        should contain_mesos__property('master_quorum').with_value(mesos_quorum)
        should contain_mesos__property('master_registry').with_value('replicated_log')
        should contain_mesos__property('master_registry_store_timeout').with_value('10secs')
        should contain_mesos__property('master_root_submissions').with_value(true)
        should contain_mesos__property('master_slave_removal_rate_limit').with_value('100/1mins')
      }
    end
  end

  context 'includes all services' do
    let(:params) {
      {
        :api => '1.0',
        :watcher => 'latest',
        :baragon => '0.1.5',
        :dns => 'v0.1.0',
      }
    }

    it {
      should contain_class('acquia_mesos::services::api')
      should contain_class('acquia_mesos::services::watcher')
      should contain_class('acquia_mesos::services::baragon')
      should contain_class('acquia_mesos::services::dns::master')
    }
  end
end
