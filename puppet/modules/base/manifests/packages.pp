class base::packages {
  $common_packages = [
    'byobu',
    'grep',
    'ethtool',
    'htop',
    'lvm2',
    'pv',
    'screen',
    'strace',
    'syslog-ng',
    'sysstat',
    'tmux',
    'tree',
    'unzip',
    'vim-enhanced',
    'zip',
  ]

  package { $common_packages:
    ensure => latest,
  }

  package { 'nemesis-puppet':
    ensure => latest,
  }
}
