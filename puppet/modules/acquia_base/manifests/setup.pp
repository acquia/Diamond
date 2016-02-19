class acquia_base::setup {
  unless $supports_trim {
    acquia_base::setup::device_setup { $aws_block_devices:
      before => [
        File['/mnt/lib'],
        File['/mnt/log'],
        File['/mnt/tmp'],
      ],
    }
  }

  ensure_resource('file', '/mnt/lib',
    {
      'ensure' => 'directory',
      'mode'   => '0755',
    }
  )

  ensure_resource('file', '/mnt/log',
    {
      'ensure' => 'directory',
      'mode'   => '0755',
    }
  )

  ensure_resource('file', '/mnt/tmp',
    {
      'ensure' => 'directory',
      'mode'   => '1777',
    }
  )

  file { '/etc/profile.d/nemesis_rubylib.sh':
    ensure  => present,
    content => 'export RUBYLIB=/etc/puppet/lib:$RUBYLIB',
  }
}
