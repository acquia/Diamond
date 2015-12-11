class acquia_base {
  include acquia_base::admin_users
  include acquia_base::sudo
  include acquia_base::puppet
  include acquia_base::docker
  include acquia_base::diamond

  contain acquia_base::selinux
  contain acquia_base::repos
  contain acquia_base::packages
  contain acquia_base::instance_store
  contain acquia_base::setup

  Class['acquia_base::selinux'] ->
  Class['acquia_base::repos'] ->
  Class['acquia_base::packages'] ->
  Class['acquia_base::instance_store'] ->
  Class['acquia_base::setup']
}
