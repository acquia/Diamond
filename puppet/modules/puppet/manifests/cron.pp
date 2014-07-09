class puppet::cron {

  cron { 'puppet_run':
    command => "cd /etc/puppet; puppet apply modules/nodes.pp",
    user    => puppet,
    hour    => 0,
    minute  => *,

  }
}
