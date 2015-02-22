class sumologic::uninstall {
  file { 'sumo.conf':
    ensure => absent,
    path   => '/etc/sumologic',
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
