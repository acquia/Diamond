class tessera {
  require base::repos 
  require tessera::apache

  package { 'tessera':
    ensure  => 'latest',
    notify  => Exec['own-tessera'],
    require => [ Package['apache2'], ],
  }

  package { 'libmysqlclient-dev':
    ensure => 'latest',
    before => [Exec['initialize-mysql'], ],
  }
    
  file { '/opt/tessera/etc/config.py':
    ensure  => present,
    content => template('tessera/config.py.erb'),
    require => [ Package['tessera'], ],
  }
  
  file { [ '/opt', '/opt/tessera', '/opt/tessera/etc', '/opt/tessera/etc/log' ]:
    ensure => directory,
    before => File ['/opt/tessera/etc/config.py'],
  }

  file { '/opt/tessera/etc/tessera.wsgi':
    ensure  => present,
    source  => 'puppet:///modules/tessera/tessera.wsgi',
    mode    => 'a+x',
    require => [ Package['tessera'], ],
  }

  file { '/opt/tessera/etc/initialize_mysql.py' :
    ensure => present,
    source => 'puppet:///modules/tessera/initialize_mysql.py',
    mode   => 'a+x',
    before => [Exec['own-tessera'], ],
  }

  exec {'own-tessera':
    command     => '/bin/chown www-data:www-data /opt/tessera',
    refreshonly => true,
    require     => Package['tessera'],
  }

  apache::vhost { 'tessera':
    require                     => Package['tessera'],
    priority                    => '05',
    servername                  => 'tessera',
    serveraliases               => 'tessera',
    access_log                  => false,
    error_log                   => false,
    docroot                     => '/opt/tessera',
    port                        => 80,
    wsgi_daemon_process         => 'tessera',
    wsgi_process_group          => 'tessera',
    wsgi_import_script          => '/opt/tessera/etc/tessera.wsgi',
    wsgi_script_aliases         => {
      '/' => '/opt/tessera/etc/tessera.wsgi'
    },
    wsgi_daemon_process_options => {
      processes          => 5,
      threads            => 5,
      display-name       => '%{GROUP}',
      inactivity-timeout => 120,
      python-path        => '/opt/tessera/lib/python2.7/site-packages',
    },
    wsgi_import_script_options  => {
      process-group     => 'tessera',
      application-group => '%{GLOBAL}',
    },
  }

  exec { 'initialize-mysql':
    command => '/opt/tessera/bin/python /opt/tessera/etc/initialize_mysql.py',
    require => [File['/opt/tessera/etc/initialize_mysql.py'], ],
  }

  concat::fragment { 'tessera_directory':
    target  => '05-tessera.conf',
    order   => 13,
    content => template('tessera/apache_vhost_directory_fragment.erb')
  }

  file {'/opt/tessera/.tessera_access':
    ensure  => present,
    require => Package['tessera'],
    owner   => 'www-data',
    group   => 'www-data',
    content => template('tessera/tessera_access.erb')
  }

  exec { 'disable-default-site':
    command => '/usr/sbin/a2dissite 000-default && service apache2 reload',
    onlyif  => '/usr/sbin/a2query -c 000-default',
    require => [Package['tessera'], ],
  }

}
