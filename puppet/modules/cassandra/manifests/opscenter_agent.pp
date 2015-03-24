class cassandra::opscenter_agent {
  package {'datastax-agent':
    ensure  => 'latest',
    require => [ Service['cassandra'], ],
  }

  file {'/var/lib/datastax-agent/conf/address.yaml':
    mode    => '0644',
    require => Package['datastax-agent'],
    content => template('cassandra/opscenter_agent_address.yaml.erb'),
    notify  => Service['datastax-agent']
  }

  service {'datastax-agent':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Service['cassandra'],
      Package['datastax-agent'],
      File['/var/lib/datastax-agent/conf/address.yaml'], ],
  }
}
