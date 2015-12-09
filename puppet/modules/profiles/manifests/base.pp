class profiles::base {
  contain ::acquia_base
  include selinux
  include ntp
  include logrotate::base
}
