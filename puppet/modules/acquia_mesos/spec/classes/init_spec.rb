require 'spec_helper'

describe 'acquia_mesos', :type => :class do
  let(:facts) {
    {
      :operatingsystem => 'Ubuntu',
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
      :lsbdistid => 'Ubuntu',
    }
  }

  it { should compile }

  context 'creates all necessary directories' do
    it { should contain_file('/var/lib/mesos').with_ensure('link') }
    it { should contain_file('/mnt/tmp/mesos').with_mode('0755') }
  end

  context 'installs the correct version' do
    let(:version) { '0.23.0' }
    let(:repo) { 'mesosphere' }

    let(:params) {
      {
        :mesos_repo => repo,
        :mesos_version => version,
      }
    }

    it { should contain_class('mesos').with_version(version) }
    it do
      should contain_apt__source('mesosphere')
        .with_location('http://repos.mesosphere.io/ubuntu')
        .with_release('trusty')
        .with_repos('main')
        .with_key('81026D0004C44CF7EF55ADF8DF7D54CBE56151BF')
    end
  end

  context 'includes mesos-slave' do
    it {
      should contain_class('acquia_mesos::slave')
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
      ).with_content(%r{\/var\/log\/mesos\/\*\.log})
    }

    it {
      should contain_logrotate__rule('mesos').with(
        {
          'path'      => '/var/log/mesos/*.log',
          'rotate'    => '7',
          'size'      => '250M',
          'missingok' => true,
        }
      )
    }
  end
end
