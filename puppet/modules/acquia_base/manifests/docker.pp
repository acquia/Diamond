class acquia_base::docker(
  $version = 'latest',
) {
  include acquia_base::docker::docker_gc

  file { '/mnt/lib/docker':
    ensure  => directory,
    require => [ File['/mnt/lib'], ],
  }

  class { '::docker':
    package_name                => 'docker-engine',
    version                     => "${version}",
    use_upstream_package_source => true,
    root_dir                    => '/mnt/lib/docker',
    tmp_dir                     => '/mnt/tmp',
    storage_driver              => 'overlay',
    require                     => [
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
