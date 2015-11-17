class profiles::zookeeper {
  contain profiles::base
  contain profiles::java
  include ::acquia_zookeeper

  Class['profiles::base'] ->
  Class['profiles::java'] ->
  Class['::acquia_zookeeper']
}
