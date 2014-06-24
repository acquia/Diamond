class base::sudo {
  package {'sudo':
    ensure => installed,
  }

  # Remove the default Ubuntu user's sudo access
  file { '/etc/sudoers.d/90-cloudimg-ubuntu':
    ensure => absent,
  }

  file {'/etc/sudoers/':
    mode      => '0440',
    source    => 'puppet:///modules/base/sudoers',
    show_diff => false,
  }
}
