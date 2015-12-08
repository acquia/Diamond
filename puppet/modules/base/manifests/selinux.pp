class base::selinux {
  class { 'selinux':
    mode => 'permissive',
  }
}
