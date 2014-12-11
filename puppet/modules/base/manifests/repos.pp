class base::repos {
  class { 'apt':
    apt_update_frequency => 'daily',
    purge_sources_list_d => true,
  }

  apt::source { 'nemesis':
    location    => "http://${::custom_repo}.s3.amazonaws.com",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '23406CA7',
    key_server  => 'pgp.mit.edu',
    include_src => false,
  }

  apt::ppa { 'ppa:webupd8team/java': }
}
