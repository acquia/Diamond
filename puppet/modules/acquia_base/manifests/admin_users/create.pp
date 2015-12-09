define acquia_base::admin_users::create(
  $ensure         = present,
  $groups         = ['wheel'],
  $key            = undef,
  $shell          = '/bin/bash',
  $type           = 'ssh-rsa',
){

  # To create an admin user you need to add information to hiera
  #
  # acquia_base::admin_users::accounts:
  #   admin:
  #     key: asdfkjhasdfjasdflkjhasdfj
  #   pleb:
  #     key: asdfasdfasdfasdf
  #     type: ssh-dss
  #     groups:
  #       - www-data
  #       - zookeeper
  #     shell: /bin/csh
  #   ubuntu:
  #     ensure: absent
  #

  user { $title:
    ensure     => $ensure,
    name       => $title,
    shell      => $shell,
    managehome => true,
    groups     => $groups,
  }

  if ($key != '') {
    ssh_authorized_key { $title:
      ensure => $ensure,
      name   => $title,
      user   => $title,
      type   => $type,
      key    => $key,
    }
  }
}
