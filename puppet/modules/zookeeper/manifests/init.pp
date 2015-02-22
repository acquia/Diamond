class zookeeper{
  require base::repos
  require java
  
  package { 'zookeeper' :
    ensure => latest,
  }

  package { 'zookeeper-exhibitor' :
    ensure  => latest,
    require => [ Package['zookeeper'], ],
  }

  file { ['/opt/zookeeper', '/opt/zookeeper/transactions', '/opt/zookeeper/snapshots' ]:
    ensure  => directory,
    require => [ Package['zookeeper'], ],
  }

  file { '/opt/exhibitor/web.xml':
    ensure  => present,
    source  => 'puppet:///modules/zookeeper/web.xml',
    mode    => 'a+x',
    require => [ Package['zookeeper-exhibitor'], ],
  }

  file { '/opt/exhibitor/defaults.conf':
    ensure  => present,
    content => template('zookeeper/defaults.conf.erb'),
    require => [ Package['zookeeper-exhibitor'], ],
  }
  
  file { '/opt/exhibitor/credentials.properties':
    ensure  => present,
    content => template('zookeeper/credential.properties.erb'),
    require => [ Package['zookeeper-exhibitor'], ],
  }

  file { '/etc/init.d/exhibitor':
    ensure  => present,
    content => template('zookeeper/init.d.erb'),
    mode    => '0755',
    require => [ Package['zookeeper-exhibitor'], ],
  }

  file { '/opt/exhibitor/realm':
    ensure  => present,
    content => template('zookeeper/realm.erb'),
    mode    => '0755',
    require => [ Package['zookeeper-exhibitor'], ],
  }
  
  service { 'exhibitor':
    ensure  => 'running',
    require => [ File['/etc/init.d/exhibitor'], File['/opt/exhibitor/realm'], File['/opt/exhibitor/web.xml'], File['/opt/exhibitor/defaults.conf'], File['/opt/exhibitor/credentials.properties'], ],
  }

}