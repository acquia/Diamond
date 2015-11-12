class base::repos {
  if !defined(Class['yum']) {
    class { 'yum': }
  }

  if $::custom_repo {
    file { '/etc/yum.repos.d/nemesis.repo':
      ensure  => present,
      content => "[nemesis]\nname=Nemesis Repository\nbaseurl=http://${::custom_repo}.s3.amazonaws.com/repo/main/centos/7\nenabled=1\ngpgcheck=1\ngpgkey=http://${::custom_repo}.s3.amazonaws.com/repo/gpg\n",
    }
  }

  package { 'yum-cron':
    ensure => present,
  }

  file { '/etc/yum/yum-cron.conf':
    ensure  => present,
    require => Package['yum-cron'],
    source  => 'puppet:///modules/base/yum_cron',
  }
}
