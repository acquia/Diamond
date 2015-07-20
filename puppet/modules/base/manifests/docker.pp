class base::docker {
  class { '::docker':
    root_dir => '/mnt/lib/docker',
    tmp_dir  => '/mnt/tmp',
  }

  file { '/mnt/lib/docker':
    ensure  => directory,
    require => File['/mnt/lib'],
  }
}
