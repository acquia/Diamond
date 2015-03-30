define graphite::config($owner = 'www-data', $group = 'www-data', $file = $title) {
  file { "/opt/graphite/conf/carbon-daemons/writer/${file}":
    ensure  => present,
    source  => "puppet:///modules/graphite/carbon-daemons/writer/${file}",
    owner   => $::owner,
    group   => $::group,
    require => [ File['writer'], Package['graphite'], ],
    notify  => Service['carbon-daemon'],
  }
}
