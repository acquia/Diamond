class java {
  require base

  package { 'openjdk-7-jre-headless':
    ensure => present,
  }

  file { '/tmp/java.preseed':
    source => 'puppet:///modules/java/java.preseed',
    mode   => '0600',
  }

  package { 'oracle-jdk7-installer':
    ensure       => installed,
    responsefile => '/tmp/java.preseed',
    require      => [ File['/tmp/java.preseed'], Package['openjdk-7-jre-headless'] ],
  }

  package { 'oracle-java7-set-default':
    ensure  => installed,
    require => [ Package['oracle-jdk7-installer'], ],
  }

  package{'libjna-java':
    ensure => installed,
  }
}
