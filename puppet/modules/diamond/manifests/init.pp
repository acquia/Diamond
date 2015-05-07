class diamond (
  $cassandra = false,
){
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
    ensure  => '3.1.1~acquia1',
    require => User['diamond'],
  }

  service { 'diamond':
    ensure  => running,
    require => Package['diamond'],
  }

  file {'/mnt/log/diamond':
    ensure  => directory,
    owner   => 'diamond',
    group   => 'diamond',
    require => [ User['diamond'], Group['diamond'] ],
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

  file {'/etc/diamond/collectors':
    ensure  => directory,
    owner   => 'diamond',
    group   => 'diamond',
    mode    => '0644',
    require => Package['diamond'],
  }

  if (str2bool($::acquia_cloudwatch)) {
    # Cloudwatch contains config fragments for different services.
    concat {'/etc/diamond/handlers/cloudwatchHandler.conf':
      ensure  => present,
      notify  => Service['diamond'],
      owner   => 'diamond',
      group   => 'diamond',
      mode    => '0644',
      require => [ Package['diamond'], File['/etc/diamond/handlers'] ],
    }

    # Default cloudwatch handler fragment.
    concat::fragment {'cloudwatchHandlerHeader':
      target  => '/etc/diamond/handlers/cloudwatchHandler.conf',
      content => template('diamond/cloudwatchHandler.conf.erb'),
      order   => '01',
    }

    if ($cassandra) {
      # Cassandra cloudwatch handler fragment.
      concat::fragment {'cloudwatchHandlerCassandra':
        target => '/etc/diamond/handlers/cloudwatchHandler.conf',
        source => 'puppet:///modules/diamond/cloudwatch_handlers/cassandra.conf',
        order  => '03',
      }
    }
  }
  else {
    file {'/etc/diamond/handlers/cloudwatchHandler.conf':
      ensure => absent,
      notify => Service['diamond'],
    }
  }

  if ($cassandra) {
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
