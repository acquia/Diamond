class graphite {
  include apt
  require graphite::apache

  $version = '0.1.1-0~trusty'

  package { 'libcairo2':
    ensure => 'latest',
  }

  package { 'graphite':
    ensure  => $version,
    notify  => Exec['own-graphite'],
    require => [ Package['apache2'], Package['libcairo2']],
  }


  exec { 'own-graphite':
    command     => '/bin/chown -R www-data:www-data /opt/graphite',
    refreshonly => true,
    require     => Package['graphite'],
  }

  exec { 'syncdb':
    command => 'bash -c "/opt/graphite/bin/python /opt/graphite/webapp/graphite/manage.py syncdb --noinput"',
    onlyif  => 'bash -c "test ! -f /opt/graphite/storage/graphite.db"',
    require => Package['graphite'],
    path    => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
  }

  exec { 'setup_db_permissions':
    command => '/bin/chown -R www-data:www-data /opt/graphite/storage',
    require => [ Package['graphite'], Exec['syncdb'], ],
  }

  file { 'writer':
    ensure  => directory,
    path    => '/opt/graphite/conf/carbon-daemons/writer',
    group   => 'www-data',
    owner   => 'www-data',
    require => Package['graphite'],
  }

  graphite::config { 'aggregation-filters.conf': }
  graphite::config { 'aggregation-rules.conf': }
  graphite::config { 'aggregation.conf': }
  graphite::config { 'amqp.conf': }
  graphite::config { 'daemon.conf': }
  graphite::config { 'filter-rules.conf': }
  graphite::config { 'listeners.conf': }
  graphite::config { 'management.conf': }
  graphite::config { 'relay-rules.conf': }
  graphite::config { 'relay.conf': }
  graphite::config { 'rewrite-rules.conf': }
  graphite::config { 'storage-rules.conf': }
  graphite::config { 'writer.conf': }

  file { '/opt/graphite/conf/graphite.wsgi':
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/graphite/graphite.wsgi',
    owner   => 'www-data',
    group   => 'www-data',
    require => [ Package['graphite'], ],
  }

  file { '/opt/graphite/webapp':
    ensure  => directory,
    require => Package['graphite'],
    owner   => 'www-data',
    group   => 'www-data',
  }

  file { '/opt/graphite/webapp/graphite/local_settings.py':
    ensure  => present,
    content => template('graphite/local_settings.py.erb'),
    owner   => 'www-data',
    group   => 'www-data',
    require => [ Package['graphite'], ],
  }

  apache::vhost { 'graphite':
    require                     => Package['graphite'],
    priority                    => '05',
    servername                  => 'graphite',
    serveraliases               => 'graphite',
    docroot                     => '/opt/graphite/webapp',
    port                        => 80,
    wsgi_daemon_process         => 'graphite',
    wsgi_process_group          => 'graphite',
    wsgi_import_script          => '/opt/graphite/conf/graphite.wsgi',
    wsgi_script_aliases         => {
      '/' => '/opt/graphite/conf/graphite.wsgi'
    },
    wsgi_daemon_process_options => {
      processes          => 5,
      threads            => 5,
      display-name       => '%{GROUP}',
      inactivity-timeout => 120,
      python-path        => '/opt/graphite/lib/python2.7/site-packages',
    },
    wsgi_import_script_options  => {
      process-group     => 'graphite',
      application-group => '%{GLOBAL}',
    },
    directories                 => [
      {
        path                => '/opt/graphite/webapp/',
        allow_override      => ['All'],
        options             => ['FollowSymLinks'],
        auth_type           => 'Basic',
        auth_user_file      => '/opt/graphite/.graphite_access',
        auth_basic_provider => 'file',
        auth_name           => 'Login Required',
        auth_require        => 'valid-user',
      },
      {
        path  => '/opt/graphite/conf/',
        allow_override      => ['None'],
        auth_type           => 'Basic',
        auth_user_file      => '/opt/graphite/.graphite_access',
        auth_basic_provider => 'file',
        auth_name           => 'Login Required',
        auth_require        => 'valid-user',
      },

    ],
    aliases                     => [
      {
        alias => '/content',
        path  => '/opt/graphite/webapp/content/',
      },
      {
        alias => '/media',
        path  => '/opt/graphite/lib/python2.7/site-packages/django/contrib/admin/static/admin/',
      },
    ],
  }

  # Add in the location stanzas
  concat::fragment { 'graphite_fragment':
    target  => '05-graphite.conf',
    order   => 11,
    content => template('graphite/locations.conf.erb')
  }

  file { '/opt/graphite/conf/carbon-daemons/writer/db.conf':
    ensure  => present,
    content => template('graphite/db.conf.erb'),
    require => [ Package['graphite'], File['writer'], ],
  }

  file { 'upstart_conf':
    ensure  => present,
    require => Package['graphite'],
    path    => '/etc/init/carbon-writer.conf',
    source  => 'puppet:///modules/graphite/carbon-writer.conf',
  }

  file {'/opt/graphite/.graphite_access':
    ensure  => present,
    require => Package['graphite'],
    owner   => 'www-data',
    group   => 'www-data',
    content => template('graphite/graphite_access.erb')
  }

  service { 'carbon-writer':
    ensure  => running,
    require => [ File['upstart_conf'], Package['graphite'], Exec['own-graphite'] ],
  }

  exec { 'disable-default-site':
    command => '/usr/sbin/a2dissite 000-default && service apache2 reload',
    onlyif  => '/usr/sbin/a2query -c 000-default',
    require => Package['graphite'],
  }

}
