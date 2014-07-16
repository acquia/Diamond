class graphite::packages {
  $version = '0.1.0-acquia~precise1'

  package { 'graphite':
    ensure => $version,
  }
}
