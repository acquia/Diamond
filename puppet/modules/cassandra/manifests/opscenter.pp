class cassandra::opscenter {
  require java

  # OpsCenter Version
  # When changing this the opscenter_passwd.db.erb template needs to also be updated to include the new version
  $opscenter_version = '5.1.0'

  file { '/mnt/log/opscenter':
    ensure => 'directory',
    mode   => '0755',
  }

  file { '/mnt/lib/opscenter':
    ensure => 'directory',
    mode   => '0755',
  }

  package { 'opscenter':
    ensure  => $opscenter_version,
  }

  file { '/etc/opscenter/opscenterd.conf':
    ensure  => present,
    content => template('cassandra/opscenterd.conf.erb'),
    require => Package['opscenter'],
    notify  => Service['opscenterd'],
  }

  file { '/etc/opscenter/clusters':
    ensure  => 'directory',
    mode    => '0755',
    require => [ Package['opscenter'], ],
  }

  file {"/etc/opscenter/clusters/${::cassandra_cluster_name}.conf":
    ensure  => present,
    content => template('cassandra/opscenter_cluster_name.conf.erb'),
    require => [ Package['opscenter'], File['/etc/opscenter/clusters'], ],
    notify  => Service['opscenterd'],
  }

  package {'sqlite':
    ensure  => 'latest',
  }

  file {'/etc/opscenter/passwd.sql':
    ensure  => present,
    content => template('cassandra/opscenterd_passwd.db.erb'),
    require => Package['opscenter'],
  }

  exec {'create_sql_db':
    cwd     => '/etc/opscenter',
    command => '/usr/bin/sqlite3 < /etc/opscenter/passwd.sql',
    require  => [ Package['opscenter'], Package['sqlite'], File['/etc/opscenter/passwd.sql'], ],
    notify  => Service['opscenterd'],
  }

  service { 'opscenterd':
    ensure  => 'running',
    enable  => true,
    require => Package['opscenter'],
  }
}

