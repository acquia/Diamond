require 'spec_helper'

describe 'acquia_mesos::slave', :type => :class do
  it { should compile.with_all_deps }

  context 'configures a mesos slave' do
    it {
      should contain_class('mesos::slave').with_work_dir('/mnt/lib/mesos')
    }

    it {
      should contain_service('mesos-slave').with(
        :enable => true
      )
    }

    context 'configures mesos options' do
      let(:hostname) { 'test' }

      let(:facts) {
        {
          :hostname => hostname,
        }
      }

      it {
        should contain_mesos__property('containerizers').with_value('docker,mesos')
        should contain_mesos__property('docker_sandbox_directory').with_value('/mnt/mesos/sandbox')
        should contain_mesos__property('enforce_container_disk_quota').with_value(true)
        should contain_mesos__property('executor_registration_timeout').with_value('5mins')
        should contain_mesos__property('hostname').with_value(hostname)
        should contain_mesos__property('perf_events').with_value(/cycles,instructions,task-clock/)
        should contain_mesos__property('registration_backoff_factor').with_value('10secs')
        should contain_mesos__property('slave_subsystems').with_value('memory,cpuacct')
        should contain_mesos__property('strict').with_value(false)
      }
    end

    context 'configures mesos resources' do
      let(:cpu) { 2 }
      let(:memory) { 1024 }
      let(:disk_space) { 10 }

      let(:facts) {
        {
          :mesos_slave_processorcount => cpu,
          :mesos_slave_memorysize_mb => memory,
          :mesos_slave_disk_space => disk_space,
        }
      }

      it {
        should contain_mesos__property('cpus').with_value(cpu)
        should contain_mesos__property('mem').with_value(memory)
        should contain_mesos__property('disk').with_value(disk_space)
        should contain_mesos__property('ports').with_value('[31000-32000]')
        should contain_mesos__property('ephemeral_ports').with_value('[32768-57344]')
      }
    end

    context 'configures mesos attributes' do
      it {
        should contain_mesos__property('host')
        should contain_mesos__property('rack')
      }
    end
  end
end
