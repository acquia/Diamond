class sumologic::install {

  group { 'sumo':
    gid => 544,
  }

  user { 'sumo':
    ensure  => present,
    require => Group['sumo'],
    uid     => 544,
    gid     => 544,
    home    => '/opt/SumoCollector/',
    shell   => '/bin/bash',
    groups  => [ 'sumo' ],
    comment => 'Sumologic Collector user',
  }

  file { '/etc/sumologic':
    ensure => 'directory',
    path   => '/etc/sumologic',
    mode   => '0644',
    owner  => 'sumo',
    group  => 'sumo',
  }

  file { 'sumo.conf':
    path    => '/etc/sumo.conf',
    content => template('sumologic/sumo.conf.erb'),
    mode    => '0700',
    owner   => 'sumo',
    group   => 'sumo',
  }

  file { 'sources.json':
    require => File['/etc/sumologic'],
    path    => '/etc/sumologic/sources.json',
    content => template('sumologic/sources.json.erb'),
    mode    => '0644',
    owner   => 'sumo',
    group   => 'sumo',
    notify  => Service['collector'],
  }

  package { 'sumocollector':
    ensure  => 'latest',
    require => [ User['sumo'], File['sumo.conf'], File['sources.json'], ],
  }

  service { 'collector':
    ensure  => running,
    require => Package['sumocollector'],
    enable  => true,
  }
}
