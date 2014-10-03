define graphite::config($file = $title) {
  file { "/opt/graphite/conf/carbon-daemons/writer/${file}":
    ensure  => present,
    source  => "puppet:///modules/graphite/carbon-daemons/writer/${file}",
    require => [ File['writer'], Package['graphite'], ],
    notify  => Service['carbon-writer'],
  }
}
