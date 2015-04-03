class base::repos {
  class {'apt':
    purge_sources_list_d => false,
  }

  # Automatic daily security updates
  class {'apt::unattended_upgrades':
    enable    => true,
    origins   => ["${::lsbdistid}:${::lsbdistcodename}-security"],
    update    => '1',
    download  => '1',
    upgrade   => '1',
    autoclean => '7',
  }

  if $::custom_repo {
    apt::source { 'nemesis':
      location    => "http://${::custom_repo}.s3.amazonaws.com",
      release     => $::lsbdistcodename,
      repos       => 'main',
      key         => '23406CA7',
      key_server  => 'pgp.mit.edu',
      include_src => false,
    }
  }

  apt::key { 'docker_key':
    key_source => 'https://get.docker.io/gpg',
    key        => 'A88D21E9',
  }

  apt::source { 'docker':
    require     => Apt::Key['docker_key'],
    location    => 'http://get.docker.io/ubuntu',
    release     => 'docker',
    repos       => 'main',
    key         => 'A88D21E9',
    include_src => false,
  }

  apt::ppa { 'ppa:webupd8team/java': }
}
