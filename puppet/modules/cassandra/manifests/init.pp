class cassandra {
  require base
  require java

  $cassandra_version = '2.1.0-2'

  group {'cassandra':
    gid => 535,
  }

  user {'cassandra':
    ensure  => present,
    require => Group['cassandra'],
    uid     => 535,
    gid     => 535,
    home    => '/etc/cassandra',
    shell   => '/bin/false',
    comment => 'Cassandra user',
  }

  file { '/var/lib/cassandra':
    ensure  => 'directory',
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0755',
    require => [ User['cassandra'], ],
  }

  file { '/var/log/cassandra':
    ensure  => 'directory',
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0755',
    require => [ User['cassandra'], ],
  }

  package {'cassandra':
    ensure  => $cassandra_version,
    name    => 'cassandra',
    require => [
      User['cassandra'],
      File['/var/lib/cassandra'],
      File['/var/log/cassandra'],
    ],
  }

  service {'cassandra':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['cassandra'],
  }

  file {'/usr/share/cassandra/lib/jna.jar':
    ensure  => link,
    target  => '/usr/share/java/jna.jar',
    require => Package['cassandra'],
    notify  => [ Service['cassandra'], ],
  }

  file {'/etc/cassandra/cassandra.yaml':
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    content => template('cassandra/cassandra.yaml.erb'),
    require => Package['cassandra'],
    notify  => [ Service['cassandra'], ],
  }

  file {'/etc/default/cassandra':
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    content => template('cassandra/cassandra_default.erb'),
    require => Package['cassandra'],
    notify  => [ Service['cassandra'], ],
  }

  package {'tablesnap':
    ensure  => 'latest',
    name    => 'tablesnap',
    require => Service['cassandra'],
  }

  file {'/etc/default/tablesnap':
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    require => Package['tablesnap'],
    content => template('cassandra/tablesnap.erb'),
    notify  => Service['tablesnap']
  }

  service {'tablesnap':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ Package['tablesnap'], File['/etc/default/tablesnap'], ],
  }

}
