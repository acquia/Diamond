class cassandra::cassandra {
  require base::base
  require java::java

  $cassandra_version = '2.0.8'

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

  file {'/usr/share/cassandra/lib/jna.jar':
    ensure  => link,
    target  => '/usr/share/java/jna.jar',
    require => Package['cassandra'],
  }

  #file {'ah-config-cassandra':
  #  path   => '/usr/local/sbin/ah-config-cassandra',
  #  source => 'puppet:///modules/cassandra/ah-config-cassandra.rb',
  #  mode   => '0755',
  #}

}
