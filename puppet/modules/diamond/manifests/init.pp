class diamond {
  require base::repos
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

  package { 'diamond':
    ensure  => latest,
    require => User['diamond'],
  }

  service { 'diamond':
    ensure  => running,
    require => Package['diamond'],
  }

  file {'/etc/diamond/diamond.conf':
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => Package['diamond'],
    content => template('diamond/diamond.conf.erb'),
    notify  => Service['diamond'],
  }

  file {'/etc/diamond/handlers':
    ensure  => directory,
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => Package['diamond'],
  }

  file {'/etc/diamond/handlers/cloudwatchHandler.conf':
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => [ Package['diamond'], File['/etc/diamond/handlers'] ],
    content => template('diamond/cloudwatchHandler.conf.erb'),
    notify  => Service['diamond'],
  }
}
