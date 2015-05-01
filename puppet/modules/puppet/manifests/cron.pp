class puppet::cron {

  file { 'cron_script':
    path   => '/usr/local/bin/run_puppet',
    mode   => '0755',
    source => 'puppet:///modules/puppet/run_puppet',
  }

  # Run Puppet once an hour at a random time
  # This is fixed per node using fqdn_rand
  cron { 'puppet_run':
    require => File['cron_script'],
    command => '/usr/local/bin/run_puppet',
    user    => 'root',
    minute  => fqdn_rand(60),
  }
}
