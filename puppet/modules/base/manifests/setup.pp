class base::setup {
  file { '/mnt/log':
    ensure => directory,
  }

  file { '/mnt/lib':
    ensure => directory,
  }

  file { '/vol/':
    ensure => directory,
  }

  file { '/vol/ephemeral0':
    ensure => link,
    target => '/mnt/',
  }
}
