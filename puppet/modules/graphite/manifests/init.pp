class graphite {
  include apt
  require graphite::packages

  file {'writer':
    ensure => directory,
    path   => '/opt/graphite/conf/carbon-daemons/writer',
    group  => 'www-data',
    owner => 'www-data',
  }

}
