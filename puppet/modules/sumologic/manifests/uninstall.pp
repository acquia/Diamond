class sumologic::uninstall {
  file { 'sumo.conf':
    path   => '/etc/sumologic',
    ensure => absent,
  }

  file { '/opt/SumoCollector/config/wrapper.conf':
    ensure => absent,
  }

  package { 'sumocollector':
    ensure => absent,
  }

  user { 'sumo':
    ensure => absent,
  }
}
