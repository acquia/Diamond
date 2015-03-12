class cassandra::opscenter {
  require java

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

  file { "/etc/opscenter/clusters/${::cassandra_cluster_name}.conf":
    ensure  => present,
    content => template('cassandra/opscenter_cluster_name.conf.erb'),
    require => [ Package['opscenter'], File['/etc/opscenter/clusters'], ],
    notify  => Service['opscenterd'],
  }

  service { 'opscenterd':
    ensure  => 'running',
    enable  => true,
    require => Package['opscenter'],
  }
}