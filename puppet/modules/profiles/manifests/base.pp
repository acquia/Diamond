class profiles::base {
  contain ::base
  include ntp
  include logrotate::base
}
