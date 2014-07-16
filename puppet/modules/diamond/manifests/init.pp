class diamond {
  include apt
  require diamond::packages

  group { 'diamond':
    ensure => present,
  }

  user { 'diamond':
    ensure  => present,
    require => Group['diamond'],
    home    => '/etc/diamond',
    shell   => '/bin/false',
    comment => 'Diamond user',
  }

  python::pip { 'diamond':
    ensure  => present,
    pkgname => 'diamond',
  }

  service { 'diamond':
    ensure => running,
  }
}
