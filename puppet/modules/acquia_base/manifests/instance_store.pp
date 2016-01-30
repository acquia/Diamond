# Class to automatically manage AWS instance store volumes
#
# It uses LVM to automatically manage and format instance store and handles
# cases where some instances, namely the c3's, already have some instance
# store volumes formatted at launch
#
# AWS currently exposes the root fs as /dev/xvda
# Instance stores are exposed as /dev/xvd* and /dev/xvdb is the device that
# some instances pre-format and mount
class acquia_base::instance_store (
  $base_block_device = '/dev/xvdb',
  $mount_path   = '/mnt',
  $ephemeral_path = '/vol',
){
  # Only configure LVM if this is a known server type that uses instance store
  # volumes and they're configured to be present
  if $::needs_blockdevices_mounted and $::aws_block_devices {
    $base_logical_volume = {
      'instance-pool' => {
        'mountpath' => $mount_path,
        'fs_type'   => 'xfs',
        'size'      => undef,
        'options'   => 'defaults',
      },
    }

    $logical_volumes = merge($base_logical_volume,
      ephemeral_volumes($::blockdevices, $ephemeral_path)
    )

    # Define a simple 1 VG, n PVs, n LVs scheme set to use all available space
    class { 'lvm':
      volume_groups => {
        'instance-data' => {
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

