class java {
  require base

  package { 'oracle-jdk-7':
    ensure => '1.7.0-60-acquia1',
  }

  package{'libjna-java':
    ensure => installed,
  }
}
