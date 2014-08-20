class diamond {
  include apt
  require diamond::metrics_list
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
    owner => 'diamond',
    group => 'diamond',
    mode => '0644',
    require => Package['diamond'],
    content => template('diamond/diamond.conf.erb'),
    notify => Service['diamond'],
  }

  file { '/etc/diamond/collectors/CassandraCollector.conf':
    owner => 'diamond',
    group => 'diamond',
    ensure => file,
    mode => '0644',
    content => template('diamond/CassandraCollector.conf.erb'),
    require => Package['diamond'],
  }
}
