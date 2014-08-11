class java {
  require base

  exec { "java-license-accepted":
      command => "/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections";
  }

  exec { "java-license-viewed":
      command => "/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections";
  }

  package { "oracle-java7-installer":
    ensure => installed,
    require => [ Exec["java-license-accepted"], Exec["java-license-viewed"], ],
  }

  package { "oracle-java7-set-default":
    ensure => installed,
    require => [ Package["oracle-java7-installer"], ],
  }

  package{"libjna-java":
    ensure => installed,
  }
}
