class base::setup {
  file { '/mnt/log':
    ensure => directory,
  }

  file { '/mnt/lib':
    ensure => directory,
  }

  file { '/mnt/tmp':
    ensure => directory,
  }

  file { '/vol/':
    ensure => directory,
  }

  file { '/vol/ephemeral0':
    ensure => link,
    target => '/mnt/',
  }

  file { '/etc/profile.d/nemesis_rubylib.sh':
    ensure  => present,
    content => 'export RUBYLIB=/etc/puppet/lib:$RUBYLIB',
  }
}
