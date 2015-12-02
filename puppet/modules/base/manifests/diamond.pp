class base::diamond {
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

  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
    pip        => true,
  }

  python::pip { 'boto':
    ensure  => present,
    pkgname => 'boto',
    require => Class['python'],
  }

  package { 'diamond':
    ensure  => '4.0.325-0',
    require => User['diamond'],
  }

  # @todo: configure diamond and start the service
}
