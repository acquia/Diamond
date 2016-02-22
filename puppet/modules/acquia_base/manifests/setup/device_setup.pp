# Required to reset the formatted partition information for non-trim supported ephemeral devices
# for use within the lvm group created by docker-storage-setup
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html
#
define acquia_base::setup::device_setup {
  $block_device = regsubst($name, '^\/dev\/', '')

  file { "/etc/systemd/system/device-setup-${block_device}.service":
    content => template('acquia_base/setup/device-setup.service.erb'),
  } ~> exec { "device-setup-${block_device}-systemd-reload":
    path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  } -> service { "device-setup-${block_device}":
    ensure => running,
    enable => true
  }
}
