class server_hooks::cloudwatch (
  $cassandra = false,
){
  notify {"cw cass ${cassandra}":}
  file {'/etc/nemesis/server_hooks/cloudwatch_alarms.rb':
    mode    => '0644',
    require => File['/etc/nemesis/server_hooks'],
    source  => 'puppet:///modules/server_hooks/cloudwatch_alarms.rb',
  }

  file {'/etc/nemesis/resources/alarms/generic.json':
    mode    => '0644',
    require => File['/etc/nemesis/resources'],
    source  => 'puppet:///modules/server_hooks/alarms/generic.json',
  }

  if ($cassandra) {
    file {'/etc/nemesis/resources/alarms/cassandra.json':
      mode    => '0644',
      require => File['/etc/nemesis/resources'],
      source  => 'puppet:///modules/server_hooks/alarms/cassandra.json',
    }
  }
}
