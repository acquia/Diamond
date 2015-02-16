class sumologic::sumologic (
  $username,
  $password,
  $paths
) {

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

  file { "/opt/SumoCollector/config/wrapper.conf":
    require => Package['sumocollector'],
    owner   => 'sumo',
    group   => 'sumo',
  } -> file_line { "/opt/SumoCollector/config/wrapper.conf":
    match => "^wrapper.java.command=${JAVA_COMMAND_LOCATION}",
    line => "wrapper.java.command=/usr/bin/java",
  } -> file_line { "/opt/SumoCollector/config/wrapper.conf":
    match => "^wrapper.app.parameter.3=installerSources/selected.json",
    line => $sumologic_wrapper_parameters,
  }

  package { 'sumocollector':
    require => [ User['sumo'], File['sumo.conf'], File['sources.json'], ],
    ensure  => 'latest',
  }

  service { 'collector':
    require => [ Package['sumocollector'], ],
    enable  => true,
    ensure  => running,
  }
}
