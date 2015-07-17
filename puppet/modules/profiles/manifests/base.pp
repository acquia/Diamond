class profiles::base {
  contain ::base
  include diamond
  include ntp
  include logrotate::base
  include puppet
  include server_hooks

  Class['::base'] -> Class['diamond']
}
