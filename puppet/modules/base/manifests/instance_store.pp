# Enabling this class needs to be done on a per-module basis
# We could set this dynamically using hiera and a custom fact based on the
# instance type
class base::instance_store (
  $block_device = undef,
  $mount_path   = '/mnt',
){
  require base::packages

  if $block_device {

    # Defines a simple 1 VG, 1 PV, 1 LV scheme set to use all available space
    class { 'lvm':
      volume_groups => {
        'instancevg' => {
          physical_volumes => [ $block_device ],
          logical_volumes  => {
            'islv' => {
              'mountpath' => $mount_path,
              'fs_type'   => 'ext4',
              # This makes sure that the lv is set to use all available space
              'size'      => undef,
            }
          }
        }
      }
    }

    cron { 'ssd_trim':
      require => Class['lvm'],
      command => "fstrim -v ${mount_path}",
      hour    => 0,
    }
  }
}
