class base {
  require ::ntp
  require base::admin_users
  require base::packages
  require base::repos
  require base::setup
  require base::sudo
  require diamond
  require puppet
  require server_hooks

}
