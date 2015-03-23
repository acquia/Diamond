# Class to automatically manage AWS instance store volumes
#
# It uses LVM to automatically manage and format instance store and handles
# cases where some instances, namely the c3's, already have some instance
# store volumes formatted at launch
#
# AWS currently exposes the root fs as /dev/xvda
# Instance stores are exposed as /dev/xvd* and /dev/xvdb is the device that
# some instances pre-format and mount
class base::instance_store (
  $base_block_device = '/dev/xvdb',
  $mount_path   = '/mnt',
  $ephemeral_path = '/vol',
){
  if $::needs_blockdevices_mounted {

    if $::ec2_instance_type != 'c3.large' and $::ec2_instance_type != 'c3.xlarge' {
      $base_logical_volume = {
        'islv' => {
          'mountpath' => $mount_path,
          'fs_type'   => 'ext4',
          'size'      => undef,
          'options'   => 'defaults,nobootwait',
        },
      }
    }
    else {
      $base_logical_volume = {}
    }

    $logical_volumes = merge($base_logical_volume,
      ephemeral_volumes($::blockdevices, $ephemeral_path)
    )

    # Define a simple 1 VG, n PVs, n LVs scheme set to use all available space
    class { 'lvm':
      volume_groups => {
        'instancevg' => {
          physical_volumes => $::aws_block_devices,
          logical_volumes  => $logical_volumes,
        }
      }
    }
    # Declare LVM as being contained by this class
    # Ensures that LVM resources are applied in the right order in the base
    # module
    contain 'lvm'

    if $::supports_trim {
      cron { 'ssd_trim':
        require => Class['lvm'],
        command => "fstrim -v ${mount_path}",
        hour    => 0,
      }
    }
  }
}
