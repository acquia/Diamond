class cassandra::tablesnap {
  package {'python-dateutil':
    ensure  => 'latest',
  }

  package {'tablesnap':
    ensure  => 'latest',
    name    => 'tablesnap',
    require => [ Package['python-dateutil'], Service['cassandra'], ],
  }

  file {'/etc/default/tablesnap':
    mode    => '0644',
    require => Package['tablesnap'],
    content => template('cassandra/tablesnap.erb'),
    notify  => Service['tablesnap']
  }

  service {'tablesnap':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Package['tablesnap'],
      File['/etc/default/tablesnap'],
    ],
  }

}
