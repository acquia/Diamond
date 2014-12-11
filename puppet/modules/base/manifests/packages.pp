class base::packages {
  require base::repos

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

  package { 'nemesis-puppet':
    ensure => latest,
  }

  file { '/usr/bin/ack':
    ensure  => link,
    require => Package['ack-grep'],
    mode    => '0755',
    target  => '/usr/bin/ack-grep',
  }
}
