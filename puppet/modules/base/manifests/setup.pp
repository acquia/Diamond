class base::setup {
  file { '/mnt/log':
    ensure => directory,
  }

  file { '/mnt/lib':
    ensure => directory,
  }
}
