require 'spec_helper'

describe 'acquia_base::docker' do
  let(:facts) do |_|
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7',
      :aws_block_devices => [],
    }
  end

  context 'docker configuration' do
    describe 'docker puppet module' do
      it {
        should contain_class('acquia_base::docker')
        should contain_package('docker').with_name('docker-engine')
        should contain_package('device-mapper')
      }
    end

    describe 'docker configuration' do
      it {
        should contain_file('/mnt/lib/docker').with_ensure('directory')

        should contain_class('docker').with_package_name('docker-engine')
        should contain_class('docker').with_root_dir('/mnt/lib/docker')
        should contain_class('docker').with_tmp_dir('/mnt/tmp')
        should contain_class('docker').with_use_upstream_package_source(true)
      }
    end

    describe 'docker-storage-setup configuration' do
      let(:facts) {
        super().merge(
          {
            :aws_block_devices => ['/dev/xvdb', '/dev/xvdc'],
          }
        )
      }
      it {
        should contain_package('docker-storage-setup')

        should contain_class('docker')
          .with_storage_driver('devicemapper')
          .with_dm_fs('xfs')
          .with_dm_thinpooldev('/dev/mapper/docker--data-docker--pool')
          .with_dm_blocksize('512K')
          .with_storage_devs('/dev/xvdb /dev/xvdc')
          .with_storage_vg('docker-data')
          .with_storage_data_size('90%FREE')
          .with_storage_min_data_size('2g')
          .with_storage_chunk_size('512K')
      }
    end
  end

  context 'enables docker-gc' do
    describe 'docker-gc script' do
      it {
        should contain_class('acquia_base::docker::docker_gc')

        should contain_file('/var/lib/docker-gc').with(
          'mode' => '0600',
          'ensure' => 'directory',
          'owner' => 'root',
          'group' => 'root'
        )

        should contain_file('/usr/sbin/docker-gc').with(
          'source' => 'puppet:///modules/acquia_base/docker/docker-gc/docker-gc',
          'mode' => '0500',
          'owner' => 'root',
          'group' => 'root'
        )

        should contain_file('/etc/docker-gc-exclude').with(
          'source' => 'puppet:///modules/acquia_base/docker/docker-gc/docker-gc-exclude',
          'mode' => '0400',
          'owner' => 'root',
          'group' => 'root'
        )
      }
    end

    describe 'docker-gc cron job' do
      let(:node) { 'testhost.example.com' }

      it {
        should contain_cron('docker-gc').with(
          'command' => '/usr/sbin/docker-gc',
          'user' => 'root',
          'hour' => 13,
          'environment' => 'GRACE_PERIOD_SECONDS=3600 LOG_TO_SYSLOG=1'
        )
      }
    end

    describe 'docker-gc-volume script' do
      it {
        should contain_file('/usr/sbin/docker-gc-volume').with(
          'source' => 'puppet:///modules/acquia_base/docker/docker-gc-volume/docker-gc-volume',
          'mode' => '0755',
          'owner' => 'root',
          'group' => 'root'
        )
      }
    end

    describe 'docker-gc-volume cron job' do
      let(:node) { 'testhost.example.com' }

      it {
        should contain_cron('docker-gc-volume').with(
          'command' => '/usr/sbin/docker-gc-volume',
          'user' => 'root',
          'hour' => 13,
        )
      }
    end
  end

  context 'enables docker registry endpoints' do
    let(:facts) {
      super().merge(
        {
          :docker_registry_endpoint => 'example.dkr.registry.com',
          :docker_registry_username => 'AWS',
          :docker_registry_password => 'password1',
        }
      )
    }

    it {
      should contain_docker__registry('example.dkr.registry.com').with(
        'username' => 'AWS',
        'password' => 'password1',
      )
    }
  end

  context 'enables docker logrotate' do
    it {
      should contain_logrotate__rule('docker').with(
        {
          'path'      => '/var/log/docker/*.log',
          'rotate'    => '7',
          'size'      => '250M',
          'missingok' => true,
        }
      )

      should contain_file('/etc/logrotate.d/docker')
        .with_owner('root')
        .with_group('root')
        .with_ensure('present')
    }
  end
end
