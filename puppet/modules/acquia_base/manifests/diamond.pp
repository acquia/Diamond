class acquia_base::diamond(
  $version = 'latest',
){
  group { 'diamond':
    ensure => present,
  }

  group { 'docker':
    ensure => present,
  }

  user { 'diamond':
    ensure  => present,
    require => [ Group['diamond'], Group['docker'] ],
    groups  => [ 'diamond', 'docker' ],
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

  package { 'diamond':
    ensure  => "${version}",
    require => User['diamond'],
  }

  python::pip { 'docker-py':
    ensure  => present,
    pkgname => 'docker-py',
    require => [ Class['python'], Package['diamond'] ],
  }

  file {'/mnt/log/diamond':
    ensure  => directory,
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => [ User['diamond'], Group['diamond'] ],
  }

  file {'/etc/diamond/diamond.conf':
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => Package['diamond'],
    content => template('acquia_base/diamond.conf.erb'),
    notify  => Service['diamond'],
  }

  file {'/etc/diamond/handlers':
    ensure  => directory,
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => Package['diamond'],
  }

  file {'/etc/diamond/collectors':
    ensure  => directory,
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => Package['diamond'],
  }

  service { 'diamond':
    ensure  => running,
    require => [
      Package['diamond'],
      File['/mnt/log/diamond'],
      File['/etc/diamond/diamond.conf'],
      Python::Pip['docker-py'],
    ],

  }

}
