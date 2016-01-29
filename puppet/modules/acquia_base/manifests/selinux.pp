class acquia_base::selinux (
  $mode = 'enforcing'
){
  class { '::selinux':
    mode => "${mode}",
  }

  # this is necessray because otherwise dhclient can't 
  # read originally unlabelled interface conf files
  exec { 'dhclient-script-context-fix':
    command => '/usr/sbin/restorecon /etc/sysconfig/network-scripts/*'
  }
}
