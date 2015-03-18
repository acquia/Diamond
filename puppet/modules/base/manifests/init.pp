class base {
  require ::ntp
  require ::logrotate::base
  require base::admin_users
  require base::instance_store
  require base::packages
  require base::repos
  require base::setup
  require base::sudo
  require diamond
  require puppet
  require server_hooks

  exec {'puppet_templatedir_deprecated':
    command => "/bin/sed -i '/^templatedir/s/^templatedir.*//' /etc/puppet/puppet.conf",
  }
}
