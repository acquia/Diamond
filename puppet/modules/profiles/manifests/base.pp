class profiles::base {
  contain ::base
  include diamond
  include ntp
  include logrotate::base
  include puppet
  include server_hooks
  include docker

  Class['::base'] -> Class['diamond']
}
