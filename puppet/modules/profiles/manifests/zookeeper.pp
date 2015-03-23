class profiles::zookeeper {
  contain profiles::base
  contain profiles::java
  include ::zookeeper

  Class['profiles::java'] -> Class['::zookeeper']
  Class['profiles::base'] -> Class['::zookeeper']
}
