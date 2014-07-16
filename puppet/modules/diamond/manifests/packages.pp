class diamond::packages {
  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
  }

  python::pip { 'boto':
    ensure  => present,
    pkgname => 'boto',
  }
}
