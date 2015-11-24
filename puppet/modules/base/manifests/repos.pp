class base::repos {
  if !defined(Class['yum']) {
    class { 'yum': }
  }

  if $::custom_repo {
    package { 'yum-plugin-s3-iam':
      ensure => '1.0.2-1',
    }

    file { '/etc/yum.repos.d/nemesis.repo':
      ensure  => present,
      content => template('base/nemesis.repo.erb'),
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
