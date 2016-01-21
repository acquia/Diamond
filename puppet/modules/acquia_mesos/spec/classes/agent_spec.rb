require 'spec_helper'

describe 'acquia_mesos::agent', :type => :class do
  let(:facts) {
    {
      :mesos_masters_private_ips => '127.0.0.3,127.0.0.4,127.0.0.5',
      :aurora_zookeeper_connection_string => '10.0.0.1:2181,10.0.0.2:2181',
      :ec2_placement_availability_zone => 'us-east-1a',
      :osfamily => 'redhat',
    }
  }

  let(:params) {
    {
      :mesos_work_dir => '/mnt/lib/mesos',
    }
  }

  it { should compile.with_all_deps }

  context 'configures a mesos agent' do
    it {
      should contain_class('mesos::slave').with_work_dir('/mnt/lib/mesos')
    }

    it {
      should contain_service('mesos-slave').with(
        :enable => true
      )
    }

    context 'configures mesos agent properties' do
      let(:ec2_hostname) { 'test' }

      let(:facts) {
        super().merge(
          {
            :ec2_local_ipv4 => '12.34.56.78',
          }
        )
      }

      it {
        should contain_mesos__property('slave_containerizers').with_value('docker,mesos')
        should contain_mesos__property('slave_docker_sandbox_directory').with_value('/mnt/mesos/sandbox')
        should contain_mesos__property('slave_enforce_container_disk_quota').with_value(true)
        should contain_mesos__property('slave_executor_registration_timeout').with_value('5mins')
        should contain_mesos__property('slave_hostname').with_value('12.34.56.78')
        should contain_mesos__property('slave_perf_events').with_value(/cycles,instructions,task-clock/)
        should contain_mesos__property('slave_registration_backoff_factor').with_value('10secs')
        should contain_mesos__property('slave_slave_subsystems').with_value('memory,cpuacct')
        should contain_mesos__property('slave_strict').with_value(false)
      }
    end

    context 'configures mesos resources' do
      let(:cpu) { 2 }
      let(:memory) { 1024 }
      let(:disk_space) { 10 }

      let(:facts) {
        super().merge(
          {
            :mesos_masters_private_ips => '127.0.0.3,127.0.0.4,127.0.0.5',
            :mesos_slave_processorcount => cpu,
            :mesos_slave_memorysize_mb => memory,
            :mesos_slave_disk_space => disk_space,
          }
        )
      }

      it {
        should contain_mesos__property('resources_cpus').with_value(cpu)
        should contain_mesos__property('resources_mem').with_value(memory)
        should contain_mesos__property('resources_disk').with_value(disk_space)
        should contain_mesos__property('resources_ports').with_value('[31000-32000]')
        should contain_mesos__property('resources_ephemeral_ports').with_value('[32768-57344]')
      }
    end

    context 'configures mesos attributes' do
      it {
        should contain_mesos__property('attributes_host')
        should contain_mesos__property('attributes_rack')
      }
    end
  end

  context 'includes all services' do
    let(:facts) {
      super().merge(
        {
          :logstream_name => 'TESTKINESIS-NAME',
        }
      )
    }

    it {
      should contain_class('acquia_mesos::services::logstream')
      should contain_class('acquia_mesos::services::dns::agent')
    }
  end
end
