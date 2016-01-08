class acquia_zookeeper (
  $version = 'present',
  $exhibitor_version = 'present',
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

  file { '/usr/lib/systemd/system/exhibitor.service':
    ensure  => present,
    content => template('acquia_zookeeper/exhibitor.service.erb'),
    mode    => '0755',
    require => Package['zookeeper-exhibitor'],
    notify  => Service['exhibitor'],
  } ->
  exec { 'exhibitor_systemctl_reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
    notify      => Service['exhibitor']
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
                  File['/usr/lib/systemd/system/exhibitor.service'],
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
