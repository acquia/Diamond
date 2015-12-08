class base {
  include base::selinux_wrapper
  include base::admin_users
  include base::sudo
  include base::puppet
  include base::docker
  include base::diamond

  contain base::selinux_wrapper
  contain base::repos
  contain base::packages
  contain base::instance_store
  contain base::setup

  Class['base::selinux_wrapper'] ->
  Class['base::repos'] ->
  Class['base::packages'] ->
  Class['base::instance_store'] ->
  Class['base::setup']
}
