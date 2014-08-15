class diamond::packages {
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
}
