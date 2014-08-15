class graphite {
  include apt
  require graphite::packages
  require graphite::apache

  file { 'writer':
    ensure => directory,
    path   => '/opt/graphite/conf/carbon-daemons/writer',
    group  => 'www-data',
    owner  => 'www-data',
  }

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

}
