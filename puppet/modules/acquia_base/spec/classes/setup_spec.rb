require 'spec_helper'

describe 'acquia_base::setup' do
  let(:facts) do |_|
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7',
      :aws_block_devices => [],
    }
  end

  context 'default instance setup' do
    describe 'setup puppet module' do
      it {
        should contain_class('acquia_base::setup')
        should contain_file('/etc/profile.d/nemesis_rubylib.sh')
      }
    end

    describe 'creates default directories' do
      it {
        should contain_file('/mnt/lib')
          .with_ensure('directory')

        should contain_file('/mnt/log')
          .with_ensure('directory')

        should contain_file('/mnt/tmp')
          .with_ensure('directory')
      }
    end
  end

  describe 'removes the existing ext3 partition' do
    let(:facts) {
      super().merge(
        {
          :aws_block_devices => ['/dev/xvdb', '/dev/xvdc'],
          :supports_trim => false,
        }
      )
    }
    it {
      # For pre-partitioned instance types (any that do not support trim [r*, i*])
      should contain_acquia_base__setup__device_setup('/dev/xvdb')
      should contain_service('device-setup-xvdb')
      should contain_exec('device-setup-xvdb-systemd-reload')
      should contain_file('/etc/systemd/system/device-setup-xvdb.service')
        .with_content(/Requires=dev-xvdb.device/)
        .with_content(%r{ExecStart=/sbin/parted /dev/xvdb rm 1})

      should contain_acquia_base__setup__device_setup('/dev/xvdc')
      should contain_service('device-setup-xvdc')
      should contain_exec('device-setup-xvdc-systemd-reload')
      should contain_file('/etc/systemd/system/device-setup-xvdc.service')
        .with_content(/Requires=dev-xvdc.device/)
        .with_content(%r{ExecStart=/sbin/parted /dev/xvdc rm 1})
    }
  end
end
