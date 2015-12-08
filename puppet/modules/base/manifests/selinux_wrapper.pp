class base::selinux_wrapper {
  class { 'selinux':
    mode => 'permissive',
  }
}
