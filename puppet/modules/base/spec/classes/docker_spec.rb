require 'spec_helper'

describe 'base::docker' do
  let(:facts) do |_|
    {
      osfamily: 'RedHat',
      operatingsystemrelease: '7',
    }
  end

  describe 'docker puppet module' do
    it {
      should contain_class('base::docker')
      should contain_package('device-mapper')
    }
  end

  describe 'docker configuration' do
    it {
      should contain_class('docker').with_root_dir('/mnt/lib/docker')
      should contain_class('docker').with_tmp_dir('/mnt/tmp')
      should contain_file('/mnt/lib/docker')
    }
  end

  describe 'docker-gc script' do
    it {
      should contain_file('/var/lib/docker-gc').with(
        'mode' => '0600',
        'ensure' => 'directory',
        'owner' => 'root',
        'group' => 'root'
      )

      should contain_file('/usr/sbin/docker-gc').with(
        'source' => 'puppet:///modules/base/docker-gc/docker-gc',
        'mode' => '0500',
        'owner' => 'root',
        'group' => 'root'
      )

      should contain_file('/etc/docker-gc-exclude').with(
        'source' => 'puppet:///modules/base/docker-gc/docker-gc-exclude',
        'mode' => '0400',
        'owner' => 'root',
        'group' => 'root'
      )
    }
  end

  describe 'docker-gc cron job' do
    it {
      should contain_cron('docker-gc').with(
        'command' => '/usr/sbin/docker-gc',
        'user' => 'root',
        'hour' => 1,
        'environment' => 'GRACE_PERIOD_SECONDS=3600 LOG_TO_SYSLOG=1'
      )
    }
  end
end
