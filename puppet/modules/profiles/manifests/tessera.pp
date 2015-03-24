class profiles::tessera {
  include profiles::base
  include ::tessera

  Class['profiles::base'] -> Class['::tessera']
}
