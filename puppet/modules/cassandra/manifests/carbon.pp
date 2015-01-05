# We have to install Carbon on Cassandra nodes in order to run the rollup process
# Note that Carbon is not actually a running daemon, it just provides the
# necessary libs for the rollup script
class cassandra::carbon {
  require base

  package { 'carbon':
    ensure => latest,
  }

  file { 'writer':
    ensure  => directory,
    path    => '/opt/graphite/conf/carbon-daemons/writer',
    group   => 'cassandra',
    owner   => 'cassandra',
    require => Package['carbon'],
  }

  file { '/opt/graphite/conf/carbon-daemons/writer/storage-rules.conf':
    ensure  => present,
    source  => 'puppet:///modules/graphite/carbon-daemons/writer/storage-rules.conf',
    require => [ File['writer'], Package['carbon'], ],
  }

  file { 'rollup':
    path    => '/usr/local/bin/rollup.sh',
    content => template('cassandra/rollup.sh.erb'),
    mode    => '0755',
  }

  cron { 'rollup':
    require => File['rollup'],
    command => '/usr/local/bin/rollup.sh',
    user    => 'cassandra',
    minute  => '*/1',
  }
}
