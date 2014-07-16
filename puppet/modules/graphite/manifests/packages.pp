class graphite::packages {
  $version = '0.1.0-acquia~trusty1'

  package { 'graphite':
    ensure  => $version,
    notify  => Exec['own-graphite'],
  }

  exec {'own-graphite':
    command => '/bin/chown www-data:www-data /opt/graphite',
  }
}
