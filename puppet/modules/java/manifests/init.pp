class java {
  require base
  include apt::ppa

  apt::ppa { "ppa:webupd8team/java": }

  exec { "java-license-accepted":
      command => "echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections";
  }

  exec { "java-license-viewed":
      command => "echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections";
  }

  package { "oracle-java7-installer":
    ensure => installed,
    require => [ Apt::Ppa["ppa:webupd8team/java"], Exec["java-license-accepted"], Exec["java-license-viewed"], ],
  }

  package { "oracle-java7-set-default":
    ensure => installed,
    require => [ Package["oracle-java7-installer"], ],
  }

  package{"libjna-java":
    ensure => installed,
  }
}
