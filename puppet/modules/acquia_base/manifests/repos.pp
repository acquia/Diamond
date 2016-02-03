class acquia_base::repos {
  if !defined(Class['yum']) {
    class { 'yum': }
  }

  if $::nemesis_repo {
    package { 'yum-plugin-s3-iam':
      ensure => '1.0.2-1',
    }

    yumrepo { 'nemesis':
      descr      => 'Nemesis Repository',
      baseurl    => "http://${nemesis_repo}.s3.amazonaws.com/repo/main/centos/7",
      gpgkey     => "http://${nemesis_repo}.s3.amazonaws.com/repo/gpg",
      gpgcheck   => false,
      s3_enabled => true,
      require    => Package['yum-plugin-s3-iam'],
    }
  }

  package { 'yum-cron':
    ensure => present,
  }

  file { '/etc/yum/yum-cron.conf':
    ensure  => present,
    require => Package['yum-cron'],
    source  => 'puppet:///modules/acquia_base/yum_cron',
  }
}
