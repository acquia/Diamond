class base::repos {
  include apt

  apt::source { 'nemesis':
    location    => 'http://acquia-dev-nemesis-repo.s3.amazonaws.com',
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '23406CA7',
    key_server  => 'pgp.mit.edu',
    include_src => false,
  }
}
