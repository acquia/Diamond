class server_hooks {

  file {'/etc/nemesis':
    ensure => directory,
    mode   => '0644',
  }

  file {'/etc/nemesis/scripts':
    ensure  => directory,
    mode    => '0644',
    require => File['/etc/nemesis'],
  }

  file {'/etc/nemesis/scripts/nemesis_server_hooks.rb':
    mode    => '0644',
    require => File['/etc/nemesis/scripts'],
    source  => 'puppet:///modules/server_hooks/nemesis_server_hooks.rb',
  }

  file {'/etc/nemesis/scripts/nemesis_server_hooks_exec.rb':
    mode    => '0644',
    require => File['/etc/nemesis/scripts'],
    source  => 'puppet:///modules/server_hooks/nemesis_server_hooks_exec.rb',
  }

  file { '/etc/cron.d/nemesis_server_hooks':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/nemesis/scripts/nemesis_server_hooks.rb'],
    content => "1 * * * *  root /usr/bin/env ruby /etc/nemesis/scripts/nemesis_server_hooks_exec.rb\n";
  }

  file {'/etc/nemesis/server_hooks':
    ensure  => directory,
    mode    => '0644',
    require => File['/etc/nemesis'],
  }

  file {'/etc/nemesis/resources':
    ensure  => directory,
    mode    => '0644',
    require => File['/etc/nemesis'],
  }

  file {'/etc/nemesis/resources/alarms':
    ensure  => directory,
    mode    => '0644',
    require => File['/etc/nemesis/resources'],
  }

  file {'/var/log/nemesis':
    ensure => directory,
    mode   => '0644',
  }

  logrotate::rule { 'nemesis':
    path          => '/var/log/nemesis/server_hooks.log',
    rotate        => 5,
    size          => '100k',
    compress      => true,
    delaycompress => true,
    dateext       => true,
    missingok     => true,
    ifempty       => false,
    create        => true,
    create_mode   => '0644',
    create_owner  => 'root',
    create_group  => 'root',
  }

  file {'/var/lock/nemesis':
    ensure => directory,
    mode   => '0644',
  }

  if (str2bool($::acquia_cloudwatch)) {
    include cloudwatch
  }
}
