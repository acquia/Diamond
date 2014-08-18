class graphite::apache {

  # TODO all of this should really use the built-in Apache management code
  file { '/etc/apache2/sites-available/graphite-web.conf':
    source => 'puppet:///modules/graphite/graphite-web.conf',
    owner  => 'www-data',
    notify => Exec['enable-graphite'],
  }

  exec { 'disable-default-site':
    command => '/usr/sbin/a2dissite 000-default && service apache2 reload',
    onlyif => '/usr/sbin/a2query -c 000-default',
  }

  exec { 'enable-graphite':
    command => '/usr/sbin/a2ensite graphite-web && service apache2 reload',
    unless  => '/usr/sbin/a2query -c graphite-web',
    require => [ Exec['disable-default-site'], ],
  }
}
