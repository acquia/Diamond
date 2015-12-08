class profiles::base {
  contain ::base
  include selinux
  include ntp
  include logrotate::base
}
