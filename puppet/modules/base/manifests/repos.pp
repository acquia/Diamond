class base::repos {
  include apt

  class { 'unattended_upgrades':
    origins => ["${::lsbdistid}:${::lsbdistcodename}-security"],
    update  => 1,
    upgrade => 1,
    auto    => {
      'remove' => true,
    }
  }

  if $::custom_repo {
    apt::source { 'nemesis':
      location => "http://${::custom_repo}.s3.amazonaws.com",
      release  => $::lsbdistcodename,
      repos    => 'main',
      key      => {
        id     => 'C62E9B8A0B2E58728DF30F8AD9AF42A123406CA7',
        server => 'pgp.mit.edu',
      },
    }
  }
}
