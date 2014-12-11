class puppet::cron {

  file { 'cron_script':
    path   => '/usr/local/bin/run_puppet',
    mode   => 0755,
    source => 'puppet:///modules/puppet/run_puppet',
  }

  cron { 'puppet_run':
    require => File['cron_script'],
    command => '/usr/local/bin/run_puppet',
    user    => 'root',
    minute  => '*/30',
  }
}
