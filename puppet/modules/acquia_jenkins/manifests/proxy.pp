class acquia_jenkins::proxy() {
  package { 'nginx':
    ensure => installed,
  }

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure  => absent,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  file { '/etc/nginx/certs':
    ensure  => directory,
    require => Package['nginx'],
  }

  file { '/etc/nginx/sites-available/jenkins-proxy':
    content => template('acquia_jenkins/jenkins-proxy.erb'),
    mode    => '0644',
    require => [ Package['nginx'], ],
  } -> file { '/etc/nginx/sites-enabled/jenkins-proxy':
    ensure  => 'link',
    target  => '/etc/nginx/sites-available/jenkins-proxy',
    require => [ Package['nginx'], File['/etc/nginx/sites-available/jenkins-proxy'], ],
    notify  => Service['nginx'],
  }

  exec { 'generate-jenkins-certs':
    command => "/usr/bin/openssl req -x509 -nodes -subj '/C=US/ST=MA/L=Boston/O=Acquia/OU=Hosting Engineering/CN=Acquia/emailAddress=hosting-eng@acquia.com' -newkey rsa:2048 -keyout /etc/nginx/certs/jenkins.key -out /etc/nginx/certs/jenkins.crt",
    creates => '/etc/nginx/certs/jenkins.key',
    require => [ File['/etc/nginx/certs'], ],
    notify  => Service['nginx'],
  }
}
