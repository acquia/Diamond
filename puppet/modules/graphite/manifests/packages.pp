class graphite::packages {
  $version = '0.1.0-1~trusty'

  package { 'graphite':
    ensure  => $version,
    notify  => Exec['own-graphite'],
  }

  exec {'own-graphite':
    command => '/bin/chown www-data:www-data /opt/graphite',
  }

  # TODO make sure this only runs once
  exec { 'syncdb':
    command => 'bash -c "source /opt/graphite/bin/activate && /opt/graphite/bin/python /opt/graphite/webapp/graphite/manage.py syncdb --noinput"',
    require => Package['graphite'],
    path      => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
  }

}
