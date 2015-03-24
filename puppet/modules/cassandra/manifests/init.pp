class cassandra {
  include cassandra::tablesnap
  include cassandra::opscenter_agent

  $cassandra_version = '2.0.13'

  exec {'check_cassandra_installed':
    command => '/bin/true',
    onlyif  => "/usr/bin/test $(dpkg-query -W -f='${Version}\n' cassandra) == ${::cassandra_version}",
  }

  file {'/usr/sbin/policy-rc.d':
    source  => 'puppet:///modules/cassandra/policy-rc.d',
    mode    => '0775',
    require => Exec['check_cassandra_installed'],
  }

  group {'cassandra':
    ensure  => present,
  }

  user {'cassandra':
    ensure  => present,
    shell   => '/bin/false',
    comment => 'Cassandra user',
    require => [
      Group['cassandra'],
    ],
  }

  file {'/mnt/lib/cassandra':
    ensure => 'directory',
    owner  => 'cassandra',
    group  => 'cassandra',
    mode   => '0755',
  }

  file { '/mnt/log/cassandra':
    ensure => 'directory',
    owner  => 'cassandra',
    group  => 'cassandra',
    mode   => '0755',
  }

  file { '/var/lib/cassandra':
    ensure  => 'link',
    target  => '/mnt/lib/cassandra',
    owner   => 'cassandra',
    group   => 'cassandra',
    require => [ File['/mnt/lib/cassandra'], ],
  }

  file { '/var/log/cassandra':
    ensure  => 'link',
    target  => '/mnt/log/cassandra',
    owner   => 'cassandra',
    group   => 'cassandra',
    require => [ File['/mnt/log/cassandra'], ],
  }

  package {'cassandra':
    ensure  => $cassandra_version,
    name    => 'cassandra',
    require => [
      File['/usr/sbin/policy-rc.d'],
      User['cassandra'],
      File['/var/log/cassandra'],
      File['/var/lib/cassandra'],
    ],
  } -> exec {'daemon_auto_start_enabled':
    command => '/bin/rm -f /usr/sbin/policy-rc.d',
    onlyif  => '/usr/bin/test -f /usr/sbin/policy-rc.d',
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

  exec {'set_jmx_addr':
    command => "/bin/sed -i '/java.rmi.server.hostname/s/^.*/JVM_OPTS=\"${JVM_OPTS} -Djava.rmi.server.hostname=${ec2_local_ipv4}\"/' /etc/cassandra/cassandra-env.sh",
    unless  => "/bin/grep 'java.rmi.server.hostname' /etc/cassandra/cassandra-env.sh | /bin/grep -En '${ec2_local_ipv4}'",
    require => [ Package['cassandra'], ],
    notify  => [ Service['cassandra'], ],
  }

  service {'cassandra':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Package['cassandra'],
    ],
  }

}
