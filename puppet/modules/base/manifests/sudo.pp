class base::sudo {
  package {'sudo':
    ensure => installed,
  }

  # Remove the default cloud-init user's sudo access
  file { '/etc/sudoers.d/90-cloud-init-users':
    ensure => absent,
  }

  file {'/etc/sudoers/':
    mode      => '0440',
    source    => 'puppet:///modules/base/sudoers',
    show_diff => false,
    owner     => 'root',
    group     => 'root',
  }
}
