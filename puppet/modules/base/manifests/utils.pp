class base::utils {

  package { 'ack-grep':
    ensure => latest,
  }

  file { '/usr/bin/ack':
    ensure  => link,
    require => Package['ack-grep'],
    mode    => '0755',
    target  => '/usr/bin/ack-grep',
  }

  package { [ 'curl', 'byobu', 'tree', 'htop', 'git', 'aria2', 'vim', 'strace' ]:
    ensure => latest,
  }

}
