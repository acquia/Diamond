class java (
  $version = 8,
){
  apt::ppa { 'ppa:webupd8team/java': }

  apt::ppa { 'ppa:openjdk-r/ppa': }

  package { "openjdk-${java::version}-jre-headless":
    ensure  => present,
    require => Apt::Ppa['ppa:openjdk-r/ppa'],
  }

  file { '/tmp/java.preseed':
    content => template('java/java.preseed.erb'),
    mode    => '0600',
  }

  package { "oracle-java${java::version}-installer":
    ensure       => installed,
    responsefile => '/tmp/java.preseed',
    require      => [
      File['/tmp/java.preseed'],
      Package["openjdk-${java::version}-jre-headless"],
      Apt::Ppa['ppa:webupd8team/java'],
      Apt::Ppa['ppa:openjdk-r/ppa'],
    ],
  }

  package { "oracle-java${java::version}-set-default":
    ensure  => installed,
    require => [ Package["oracle-java${java::version}-installer"], ],
  }

  package{'libjna-java':
    ensure => installed,
  }
}
