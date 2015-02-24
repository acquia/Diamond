class base {
  require ::ntp
  require base::admin_users
  require base::packages
  require base::repos
  require base::sudo
  require diamond
  require puppet

  file { '/mnt/log':
    ensure => directory,
  }

  file { '/mnt/lib':
    ensure => directory,
  }
}
