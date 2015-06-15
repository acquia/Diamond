class base::repos {
  class {'apt': }

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
      key         => 'C62E9B8A0B2E58728DF30F8AD9AF42A123406CA7',
      key_server  => 'pgp.mit.edu',
      include_src => false,
    }
  }
}
