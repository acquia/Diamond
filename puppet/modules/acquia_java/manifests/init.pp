class acquia_java (
  $version = 8,
){

  class { 'acquia_java::oracle':
    ensure  => 'present',
    version => $version,
  }
}
