class base::packages {
  $common_packages = [
    'ack-grep',
    'ethtool',
    'htop',
    'pv',
    'screen',
    'strace',
    'sysstat',
    'tmux',
    'unzip',
    'vim',
    'zip',
    'zsh',
  ]

  package { $common_packages:
    ensure => latest,
  }

  package { 'syslog-ng-core':
    ensure => 'latest',
  }

  package { 'syslog-ng':
    ensure  => 'latest',
    require => Package['syslog-ng-core'],
  }

  file { '/usr/bin/ack':
    ensure  => link,
    require => Package['ack-grep'],
    mode    => '0755',
    target  => '/usr/bin/ack-grep',
  }
}
