class cassandra {
  include cassandra::tablesnap

  $cassandra_version = '2.0.13'

  # Specify additional options to pass to the JVM for tuning Cassandra
  # All options should be passed as if they were on the command line
  # @todo: Decide if this actually should be stack metadata
  $custom_jvm_opts = []

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
    require => Group['cassandra'],
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
    require => File['/mnt/lib/cassandra'],
  }

  file { '/var/log/cassandra':
    ensure  => 'link',
    target  => '/mnt/log/cassandra',
    owner   => 'cassandra',
    group   => 'cassandra',
    require => File['/mnt/log/cassandra'],
  }

  file {'/etc/cassandra/log4j-server.properties':
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    source  => 'puppet:///modules/cassandra/log4j-server.properties',
    require => Package['cassandra'],
    notify  => Service['cassandra'],
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
    notify  => Service['cassandra'],
  }

  file {'/etc/cassandra/cassandra.yaml':
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    content => template('cassandra/cassandra.yaml.erb'),
    require => Package['cassandra'],
    notify  => Service['cassandra'],
  }

  file {'/etc/default/cassandra':
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    content => template('cassandra/cassandra_default.erb'),
    require => Package['cassandra'],
    notify  => Service['cassandra'],
  }

  # NOTE: This needs to be kept up to date whenver we switch Cassandra versions
  file {'/etc/cassandra/cassandra-env.sh':
    content => template('cassandra/cassandra-env.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['cassandra'],
    notify  => Service['cassandra'],
  }

  service {'cassandra':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['cassandra'],
  }

  cron { 'weekly_repair':
    ensure  => absent,
  }

}
