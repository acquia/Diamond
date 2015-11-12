class base::puppet {
  require base::cron

  # TODO This ensures that Puppet 3.8 is installed
  # Upgrade to Puppet 4 at some point
  package { 'puppetlabs-release':
    source => 'https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm'
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
    source => 'puppet:///modules/base/puppet/puppet.conf',
  }
}
