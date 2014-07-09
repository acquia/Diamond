class diamond {
  include apt
  include python
  require diamond::packages

  group { 'diamond':
    ensure => present,
  }

  user { 'diamond',
  ensure  => present,
  require => Group['diamond'],
  home    => '/etc/diamond',
  shell   => '/bin/false',
  comment => 'Diamond user',
  }

  python::pip { 'boto':
    ensure  => present,
    pkgname => 'boto',
  }

  service { 'diamond':
    ensure => running,
  }
}
