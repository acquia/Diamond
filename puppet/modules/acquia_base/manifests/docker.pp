class acquia_base::docker(
  $docker_gc_grace_period=hiera('acquia_base::docker_gc::grace_period', 3600)
) {
  class { '::docker':
    package_name                => 'docker-engine',
    version                     => '1.9.0-1.el7.centos',
    use_upstream_package_source => true,
    root_dir                    => '/mnt/lib/docker',
    tmp_dir                     => '/mnt/tmp',
    storage_driver              => 'devicemapper',
    dm_fs                       => 'xfs'
  }

  file { '/mnt/lib/docker':
    ensure  => directory,
    require => File['/mnt/lib'],
  }

  file { '/var/lib/docker-gc':
    ensure => directory,
    mode   => '0600',
    owner  => root,
    group  => root,
  }

  file { '/etc/docker-gc-exclude':
    mode      => '0400',
    source    => 'puppet:///modules/acquia_base/docker/docker-gc/docker-gc-exclude',
    show_diff => false,
    owner     => root,
    group     => root,
  }

  file { '/usr/sbin/docker-gc':
    mode      => '0500',
    source    => 'puppet:///modules/acquia_base/docker/docker-gc/docker-gc',
    show_diff => false,
    owner     => root,
    group     => root,
    require   => [File['/var/lib/docker-gc'], File['/etc/docker-gc-exclude']],
  }

  cron { 'docker-gc':
    command     => '/usr/sbin/docker-gc',
    user        => root,
    hour        => fqdn_rand(23),
    environment => "GRACE_PERIOD_SECONDS=${docker_gc_grace_period} LOG_TO_SYSLOG=1",
    require     => File['/usr/sbin/docker-gc'],
  }

  file { '/usr/sbin/docker-gc-volume':
    mode      => '0755',
    source    => 'puppet:///modules/acquia_base/docker/docker-gc-volume/docker-gc-volume',
    show_diff => false,
    owner     => root,
    group     => root,
  }

  cron { 'docker-gc-volume':
    command => '/usr/sbin/docker-gc-volume',
    user    => root,
    hour    => fqdn_rand(23),
    require => File['/usr/sbin/docker-gc-volume'],
  }

  if $docker_registry_endpoint {
    docker::registry { "${docker_registry_endpoint}":
      username => "${docker_registry_username}",
      password => "${docker_registry_password}",
      require  => Class['::docker'],
    }
  }
}
