class acquia_base::docker(
  $version = 'latest',
) {
  include acquia_base::docker::docker_gc

  file { '/mnt/lib/docker':
    ensure  => directory,
    require => File['/mnt/lib'],
  }

  package { 'docker-storage-setup':
    ensure => present,
  }

  class { '::docker':
    package_name                      => 'docker-engine',
    version                           => "${version}",
    use_upstream_package_source       => true,
    root_dir                          => '/mnt/lib/docker',
    tmp_dir                           => '/mnt/tmp',

    # Docker devicemapper setup
    storage_driver                    => 'devicemapper',
    dm_fs                             => 'xfs',
    dm_thinpooldev                    => '/dev/mapper/docker--data-docker--pool',
    dm_blocksize                      => '512K',
    dm_use_deferred_removal           => true,

    # Docker Storage Setup
    storage_devs                      => join($aws_block_devices, ' '),
    storage_vg                        => 'docker-data',
    storage_data_size                 => '90%FREE',
    storage_min_data_size             => '2g',
    storage_chunk_size                => '512K',
    storage_growpart                  => false,
    storage_auto_extend_pool          => 'yes',
    storage_pool_autoextend_threshold => '60',
    storage_pool_autoextend_percent   => '20',

    require                           => [
      Package['docker-storage-setup'],
      File['/mnt/lib/docker'],
    ],
  }

  if $docker_registry_endpoint {
    docker::registry { "${docker_registry_endpoint}":
      username => "${docker_registry_username}",
      password => "${docker_registry_password}",
      email    => "${docker_registry_email}",
      require  => Class['::docker'],
    }
  }

  logrotate::rule { 'docker':
    path          => '/var/log/docker/*.log',
    rotate        => 7,
    rotate_every  => 'day',
    size          => '250M',
    compress      => true,
    delaycompress => true,
    dateext       => true,
    missingok     => true,
    ifempty       => false,
    create        => true,
    create_mode   => '0644',
    create_owner  => 'root',
    create_group  => 'root',
  }
}
