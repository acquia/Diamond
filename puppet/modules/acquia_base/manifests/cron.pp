class acquia_base::cron {
  file { 'puppet_cron_script':
    path   => '/usr/local/bin/run_puppet',
    mode   => '0755',
    source => 'puppet:///modules/acquia_base/puppet/run_puppet',
  }

  # Run Puppet once an hour at a random time
  # This is fixed per node using fqdn_rand
  cron { 'puppet_run':
    require => File['puppet_cron_script'],
    command => '/usr/local/bin/run_puppet',
    user    => 'root',
    minute  => fqdn_rand(60),
  }
}
