class acquia_zookeeper (
  $version = '3.4.7-1',
  $exhibitor_version = '1.5.5-1',
) {
  package { 'zookeeper' :
    ensure => $version,
    notify => Exec['refresh-zookeeper'],
  }

  package { 'zookeeper-exhibitor' :
    ensure  => $exhibitor_version,
    require => Package['zookeeper'],
    notify  => Service['exhibitor'],
  }

  file { '/opt/exhibitor/web.xml':
    ensure  => present,
    source  => 'puppet:///modules/acquia_zookeeper/web.xml',
    mode    => 'a+x',
    require => Package['zookeeper-exhibitor'],
    notify  => Service['exhibitor'],
  }

  file { '/opt/exhibitor/defaults.conf':
    ensure  => present,
    content => template('acquia_zookeeper/defaults.conf.erb'),
    require => Package['zookeeper-exhibitor'],
    notify  => Service['exhibitor'],
  }

  file { '/etc/init.d/exhibitor':
    ensure  => present,
    content => template('acquia_zookeeper/init.d.erb'),
    mode    => '0755',
    require => Package['zookeeper-exhibitor'],
    notify  => Service['exhibitor'],
  }

  file { '/opt/exhibitor/realm':
    ensure  => present,
    content => template('acquia_zookeeper/realm.erb'),
    mode    => '0755',
    require => Package['zookeeper-exhibitor'],
    notify  => Service['exhibitor'],
  }

  service { 'exhibitor':
    ensure  => 'running',
    require =>  [
                  File['/etc/init.d/exhibitor'],
                  File['/opt/exhibitor/realm'],
                  File['/opt/exhibitor/web.xml'],
                  File['/opt/exhibitor/defaults.conf'],
                ],
    }

  exec { 'refresh-zookeeper':
    command     => '/usr/bin/pkill -F /opt/zookeeper/snapshots/zookeeper_server.pid',
    refreshonly => true,
    onlyif      => '/usr/bin/test -f /opt/zookeeper/snapshots/zookeeper_server.pid',
    require     => Service['exhibitor'],
  }

}
