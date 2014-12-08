class puppet::cron {

  cron { 'puppet_run':
    command => 'cd /etc/puppet && /usr/bin/puppet apply manifests/nodes.pp',
    user    => root,
    hour    => '*/1',
  }
}
