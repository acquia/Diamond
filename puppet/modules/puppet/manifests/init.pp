class puppet {
  include apt

  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main',
    key        => '4BD6EC30',
    key_server => 'pgp.mit.edu',
  }

  package { 'puppet':
    ensure => latest,
  }

  package { 'facter':
    ensure => latest,
  }

  package { 'hiera':
    ensure => latest,
  }
}
