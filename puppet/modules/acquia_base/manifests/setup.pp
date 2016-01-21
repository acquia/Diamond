class acquia_base::setup {
  ensure_resource('file', '/mnt/log',
    {
      'ensure' => 'directory',
      'mode'   => '0755',
    }
  )

  ensure_resource('file', '/mnt/lib',
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
