class graphite::apache {

  # TODO all of this should really use the built-in Apache management code
  file { '/etc/apache2/conf-available/graphite-web.conf':
    source => 'puppet:///modules/graphite/graphite-web.conf',
    owner  => 'www-data',
    notify => Exec['enable-graphite'],
  }

  exec { 'enable-graphite':
    command => '/usr/sbin/a2enconf graphite-web && service apache2 reload',
    unless  => '/usr/sbin/a2query -c graphite-web',
  }
}
