require 'spec_helper'

describe 'base::instance_store' do
  let(:facts) do |_|
    {
      blockdevices: 'xvda,xvdb,xvdc',
      ec2_instance_type: 'r3.xlarge',
      lsbdistcodename: 'trusty',
      lsbdistdescription: 'Ubuntu 14.04.2 LTS',
      lsbdistid: 'Ubuntu',
      lsbdistrelease: '14.04',
      lsbmajdistrelease: '14.04',
      osfamily: 'Debian',
      operatingsystem: 'Ubuntu',
    }.merge(
      {
        needs_blockdevices_mounted: true,
        supports_trim: true,
        aws_block_devices: ['/dev/xvdb'],
      }
    )
  end

  describe 'by default' do
    it { should compile.with_all_deps }
    it { should contain_class('base::instance_store') }
    it { should contain_physical_volume('/dev/xvdb') }
    it { should_not contain_physical_volume('/dev/xvdc') }
    it {
      should contain_lvm__volume_group('instancevg').with(
        {
          ensure: 'present',
          physical_volumes: ['/dev/xvdb'],
        }
      )
    }

    it {
      should contain_lvm__logical_volume('islv').with(
        {
          volume_group: 'instancevg',
          size: nil,
        }
      )
    }

    it {
      should contain_lvm__logical_volume('ephemeral1').with(
        {
          volume_group: 'instancevg',
          size: nil,
        }
      )
    }

    it { should contain_mount('/mnt') }
    it { should contain_cron('ssd_trim') }
  end
end
