class acquia_base::selinux {
  class { '::selinux':
    mode => 'permissive',
  }
}
