class graphite::rollup {

  file { 'rollup_config':
    ensure  => present,
    owner   => 'www-data',
    group   => 'www-data',
    path    => '/opt/graphite/rollup.json',
    content => template('graphite/rollup_config.json.erb'),
  }

  file { 'rollup_upstart':
    ensure => present,
    path   => '/etc/init/rollup.conf',
    source => 'puppet:///modules/graphite/rollup.conf',
    owner  => 'root',
    group  => 'root',
  }

  file { 'rollup_log':
    ensure => present,
    path   => '/mnt/log/cassandra-rollup.log',
    owner  => 'www-data',
    group  => 'www-data',
  }

  logrotate::rule { 'rollup_log':
    path          => '/mnt/log/cassandra-rollup.log',
    rotate        => 3,
    size          => '250M',
    compress      => true,
    delaycompress => true,
    dateext       => true,
    missingok     => true,
    ifempty       => false,
    create        => true,
    create_mode   => '0644',
    create_owner  => 'www-data',
    create_group  => 'www-data',
  }

  service { 'rollup':
    ensure  => running,
    require => [ Package['graphite'], File['rollup_log'], File['rollup_config'] ],
  }

}
