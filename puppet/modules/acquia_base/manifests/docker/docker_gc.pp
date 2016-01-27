class acquia_base::docker::docker_gc(
  $grace_period = 3600,
) {
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
    require   => [ File['/var/lib/docker-gc'], File['/etc/docker-gc-exclude'], ],
  }

  cron { 'docker-gc':
    command     => '/usr/sbin/docker-gc',
    user        => root,
    hour        => fqdn_rand(23),
    environment => "GRACE_PERIOD_SECONDS=${grace_period} LOG_TO_SYSLOG=1",
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
}
