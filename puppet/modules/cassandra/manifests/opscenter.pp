class cassandra::opscenter {
  require java

  # OpsCenter Version
  # When changing this the opscenter_passwd.db.erb template needs to also be updated to include the new version
  $opscenter_version = '5.1.0'

  exec {'check_opscenter_installed':
    command => '/bin/true',
    onlyif  => "/usr/bin/test $(dpkg-query -W -f='${Version}\n' opscenter) == ${::opscenter_version}",
  }

  file {'/usr/sbin/policy-rc.d':
    source  => 'puppet:///modules/cassandra/policy-rc.d',
    mode    => '0775',
    require => Exec['check_opscenter_installed'],
  }

  file { '/mnt/log/opscenter':
    ensure => 'directory',
    mode   => '0755',
  }

  file { '/mnt/lib/opscenter':
    ensure => 'directory',
    mode   => '0755',
  }

  package { 'opscenter':
    ensure  => 'latest',
  } -> exec {'daemon_auto_start_enabled':
    command => '/bin/rm -f /usr/sbin/policy-rc.d',
    onlyif  => '/usr/bin/test -f /usr/sbin/policy-rc.d',
  }

  file { '/etc/opscenter/clusters':
    ensure  => 'directory',
    mode    => '0755',
    require => [ Package['opscenter'], ],
  }

  file { '/etc/opscenter/opscenterd.conf':
    ensure  => present,
    content => template('cassandra/opscenterd.conf.erb'),
    require => Package['opscenter'],
    notify  => Service['opscenterd'],
  }

  file {"/etc/opscenter/clusters/${::cassandra_cluster_name}.conf":
    ensure  => present,
    content => template('cassandra/opscenter_cluster_name.conf.erb'),
    require => [ Package['opscenter'], File['/etc/opscenter/clusters'], ],
    notify  => Service['opscenterd'],
  }

  package {'sqlite':
    ensure  => 'latest',
  } -> file {'/etc/opscenter/passwd.sql':
    ensure  => present,
    content => template('cassandra/opscenterd_passwd.db.erb'),
    require => Package['opscenter'],
  } -> exec {'create_sql_db':
    cwd     => '/etc/opscenter',
    command => '/usr/bin/sqlite3 < /etc/opscenter/passwd.sql',
    creates => '/etc/opscenter/passwd.db',
    notify  => Service['opscenterd'],
  }

  service { 'opscenterd':
    ensure  => 'running',
    enable  => true,
    require => Package['opscenter'],
  }
}

