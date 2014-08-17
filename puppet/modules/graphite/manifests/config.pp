class graphite::config {
  file { 'writer':
    ensure => directory,
    path   => '/opt/graphite/conf/carbon-daemons/writer',
    group  => 'www-data',
    owner  => 'www-data',
  }

  define graphite_config($file = $title) {
    file { "/opt/graphite/conf/carbon-daemons/writer/${file}":
      ensure  => present,
      source  => "puppet:///modules/graphite/carbon-daemons/writer/${file}",
      require => File['writer'],
    }
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
}
