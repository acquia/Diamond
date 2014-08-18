# TODO This class (and whole module really) needs to be refactored
class graphite::config {
  $version = '0.1.0-1~trusty'

  define graphite_config($file = $title) {
    file { "/opt/graphite/conf/carbon-daemons/writer/${file}":
      ensure  => present,
      source  => "puppet:///modules/graphite/carbon-daemons/writer/${file}",
      require => File['writer'],
      notify  => Service['carbon-writer'],
    }
  }

  package { 'graphite':
    ensure  => $version,
    notify  => Exec['own-graphite'],
  }

  exec {'own-graphite':
    command     => '/bin/chown www-data:www-data /opt/graphite',
    refreshonly => true,
  }

  exec { 'syncdb':
    command => 'bash -c "source /opt/graphite/bin/activate && /opt/graphite/bin/python /opt/graphite/webapp/graphite/manage.py syncdb --noinput"',
    onlyif  => 'bash -c "test ! -f /opt/graphite/storage/graphite.db"',
    require => Package['graphite'],
    path    => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
  }

  file { 'writer':
    ensure  => directory,
    path    => '/opt/graphite/conf/carbon-daemons/writer',
    group   => 'www-data',
    owner   => 'www-data',
    require => Package['graphite'],
  }

  graphite_config { 'aggregation-filters.conf': }
  graphite_config { 'aggregation-rules.conf': }
  graphite_config { 'aggregation.conf': }
  graphite_config { 'amqp.conf': }
  graphite_config { 'daemon.conf': }
  graphite_config { 'filter-rules.conf': }
  graphite_config { 'listeners.conf': }
  graphite_config { 'management.conf': }
  graphite_config { 'relay-rules.conf': }
  graphite_config { 'relay.conf': }
  graphite_config { 'rewrite-rules.conf': }
  graphite_config { 'storage-rules.conf': }
  graphite_config { 'writer.conf': }

  file { '/opt/graphite/conf/graphite.wsgi':
    ensure => present,
    mode => 'a+x',
    source => 'puppet:///modules/graphite/graphite.wsgi',
  }

  file { '/opt/graphite/webapp/graphite/local_settings.py':
    ensure   => present,
    content  => template('graphite/local_settings.py.erb'),
    owner    => 'www-data',
    group    => 'www-data',
  }

  file { '/opt/graphite/conf/carbon-daemons/writer/db.conf':
    ensure  => present,
    content => template('graphite/db.conf.erb'),
    require => File['writer'],
  }

  file { 'upstart_conf':
    ensure  => present,
    require => Package['graphite'],
    path    => '/etc/init/carbon-writer.conf',
    source  => 'puppet:///modules/graphite/carbon-writer.conf',
  }

  exec { 'setup_db':
    command => "/opt/graphite/bin/python /opt/graphite/webapp/graphite/manage.py syncdb",
    creates => "/opt/graphite/storage/graphite.db",
  }

  exec { 'setup_db_permissions':
    command => "chown -R www-data:www-data /opt/graphite/storage"
  }

  service { 'carbon-writer':
    ensure  => running,
    require => [ File['upstart_conf'], Package['graphite'], Exec['own-graphite'] ],
  }
}
