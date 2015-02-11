class sumologic::install {

  group { 'sumo':
    gid => 544,
  }

  user { 'sumo':
    require => Group['sumo'],
    ensure  => present,
    uid     => 544,
    gid     => 544,
    home    => '/opt/SumoCollector/',
    shell   => '/bin/bash',
    groups  => [ 'sumo' ],
    comment => 'Sumologic Collector user',
  }

  file { '/etc/sumologic':
    path   => '/etc/sumologic',
    ensure => 'directory',
    mode   => '0644',
    owner  => 'sumo',
    group  => 'sumo',
  }

  file { 'sumo.conf':
    path   => '/etc/sumo.conf',
    source => 'puppet:///modules/sumologic/sumo.conf',
    mode   => '0700',
  }

  file { 'sources.json':
    require => File['/etc/sumologic'],
    path    => '/etc/sumologic/sources.json',
    content => template('sumologic/sources.json.erb'),
    mode    => '0644',
    owner   => 'sumo',
    group   => 'sumo',
  }

  file { 'wrapper.conf':
    ensure  => present,
    require => Package['sumocollector'],
    path    => '/opt/SumoCollector/config/wrapper.conf',
    owner   => 'sumo',
    group   => 'sumo',
    content => template('sumologic/wrapper.conf.erb'),
  }

  package { 'sumocollector':
    require => [ User['sumo'], File['sumo.conf'], File['sources.json'], ],
    ensure  => 'latest',
    notify  => File['wrapper.conf'],
  }

  service { 'collector':
    require => [ Package['sumocollector'], File['wrapper.conf'], ],
    enable  => true,
    ensure  => running,
  }
}
