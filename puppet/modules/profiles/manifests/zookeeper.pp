class profiles::zookeeper {
  contain profiles::base
  include ::acquia_zookeeper

  Class['profiles::base'] ->
  Class['::acquia_zookeeper']
}
