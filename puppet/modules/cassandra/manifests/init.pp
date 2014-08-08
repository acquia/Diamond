class cassandra {
  require base
  require java

  $cassandra_version = '2.0.8'
  $tablesnap_version = '0.6.2'

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

  package {'cassandra':
    ensure  => $cassandra_version,
    name    => 'cassandra',
    require => User['cassandra'],
  }

  service {'cassandra':
    ensure  => "running",
    enable  => "true",
    hasstatus => "true",
    hasrestart => true,
    require => Package["cassandra"],
  }

  file {'/usr/share/cassandra/lib/jna.jar':
    ensure  => link,
    target  => '/usr/share/java/jna.jar',
    require => Package['cassandra'],
    notify => [ Service["cassandra"], ],
  }

  file {'/etc/cassandra/cassandra.yaml':
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    content => cassandra_config,
    require => Package['cassandra'],
    notify => [ Service["cassandra"], ],
  }

  file {'/etc/default/cassandra':
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    content => template('cassandra/cassandra_default.erb'),,
    require => Package['cassandra'],
    notify => [ Service["cassandra"], ],
  }

  package {'tablesnap':
    ensure  => $tablesnap_version,
    name    => 'tablesnap',
    require => Service['cassandra'],
  }

  file {'tablesnap_conf':
    path    => "/etc/default/tablesnap",
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    require => Package['tablesnap'],
    content => template('cassandra/tablesnap.erb'),
    notify  => Service['tablesnap']
  }

  service {'tablesnap':
    ensure  => "running",
    enable  => "true",
    hasstatus => "true",
    hasrestart => true,
    require => [Package["tablesnap"], File['tablesnap_conf']],
  }

}
