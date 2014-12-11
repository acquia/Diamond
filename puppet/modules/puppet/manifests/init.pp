class puppet {
  include base::repos
  require puppet::cron

  apt::source { 'puppet':
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
