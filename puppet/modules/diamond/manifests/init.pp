class diamond (
  $cassandra = false
){
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

  concat {'/etc/diamond/handlers/cloudwatchHandler.conf':
    ensure => present,
    notify  => Service['diamond'],
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => [ Package['diamond'], File['/etc/diamond/handlers'] ],
  }

  concat::fragment {'cloudwatchHandlerHeader':
    target  => '/etc/diamond/handlers/cloudwatchHandler.conf',
    content => template('diamond/cloudwatchHandler.conf.erb'),
    order   => '01',
  }

  file {'/etc/diamond/collectors':
    ensure  => directory,
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => Package['diamond'],
  }

  if ($cassandra) {
    concat::fragment {'cloudwatchHandlerCassandra':
      target  => '/etc/diamond/handlers/cloudwatchHandler.conf',
      source  => 'puppet:///modules/diamond/cloudwatch_handlers/cassandra.conf',
      order   => '03',
    }

    file {'/etc/diamond/collectors/CassandraCollector.conf':
      owner   => 'diamond',
      group   => 'diamond',
      mode    => '0644',
      require => File['/etc/diamond/collectors'],
      source  => 'puppet:///modules/diamond/CassandraCollector.conf',
      notify  => Service['diamond'],
    }
  }


}
