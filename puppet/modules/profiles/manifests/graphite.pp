class profiles::graphite {
  contain profiles::base
  contain profiles::sumologic

  include ::graphite

  Class['profiles::base'] -> Class['::graphite']
}
