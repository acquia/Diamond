class puppet {
  require puppet::cron

  apt::source { 'puppet':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main',
    key        => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
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

  file { '/etc/puppet/puppet.conf':
    ensure => present,
    source => 'puppet:///modules/puppet/puppet.conf',
  }
}
