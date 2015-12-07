require 'spec_helper'

describe 'acquia_mesos', :type => :class do
  # Allow the module to supply the right provider for packages
  # See https://github.com/rodjek/rspec-puppet/issues/256
  let(:pre_condition) {
    '''
    Package {
      provider => \'yum\'
    }
    '''
  }

  let(:facts) {
    {
      :aurora_zookeeper_connection_string => '10.0.0.1:2181,10.0.0.2:2181',
      :mesos_masters => '127.0.0.2,127.0.0.3,127.0.0.4',
      :mesos_masters_private_ips => '127.0.0.3,127.0.0.4,127.0.0.5',
      :mesos_zookeeper_connection_string => 'zk://10.0.1.112:2181,10.0.2.54:2181,10.0.0.133:2181',
      :ec2_placement_availability_zone => 'us-east-1a',
      :osfamily => 'redhat',
    }
  }

  let(:params) {
    { mesos_base_dir: '/mnt' }
  }

  it { should compile }

  context 'creates all necessary directories' do
    it { should contain_file('/mnt/tmp') }
    it { should contain_file('/var/lib/mesos').with_ensure('link') }
    it { should contain_file('/mnt/tmp/mesos').with_mode('0755') }
  end

  context 'installs the correct version' do
    let(:version) { '0.23.0-1.0.centos701406' }

    let(:params) {
      {
        :mesos_version => version,
        :mesos_base_dir => '/mnt',
      }
    }

    it { should contain_class('mesos').with_version(version) }
  end

  context 'includes mesos-agent' do
    it {
      should contain_class('acquia_mesos::agent')
    }
  end

  context 'includes mesos-master' do
    let(:facts) {
      super().merge({ :mesos_master => true })
    }

    it {
      should contain_class('acquia_mesos::master')
    }
  end

  context 'enables mesos logrotate' do
    it {
      should contain_file('/etc/logrotate.d/mesos').with(
        {
          'owner'   => 'root',
          'group'   => 'root',
          'ensure'  => 'present',
        }
      ).with_content(%r{#{params[:mesos_base_dir]}\/log\/mesos\/\*\.log})
    }

    it {
      should contain_logrotate__rule('mesos').with(
        {
          'path'      => "#{params[:mesos_base_dir]}/log/mesos/*.log",
          'rotate'    => '7',
          'size'      => '250M',
          'missingok' => true,
        }
      )
    }
  end

  context 'contains logstream when kinesis enabled' do
    let(:facts) {
      super().merge({ :logstream_name => 'TESTSTREAM' })
    }
    it {
      should contain_class('acquia_mesos::logstream')
    }
  end

  context 'does not contain logstream when kinesis is disabled' do
    it {
      should_not contain_class('acquia_mesos::logstream')
    }
  end
end
