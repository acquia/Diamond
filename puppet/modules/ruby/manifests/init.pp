class ruby {

  class {'rvm': }

  #file { '/etc/rvmrc':
  #  mode   => '0664',
  #  before => Class['rvm'],
  #}

  file { '/etc/gemrc':
    ensure  => present,
    content => 'gem: --no-document',
    mode    => '0644',
  }

  rvm_system_ruby {
    'ruby-2.1.2':
      ensure      => 'present',
      default_use => true,
      build_opts  => ['--binary'],
      require     => Class['rvm'];
  }

  rvm_gem {
    'bundler':
      ensure       => 'latest',
      name         => 'bundler',
      ruby_version => 'ruby-2.1.2',
      require      => [ Class['rvm'], Rvm_system_ruby['ruby-2.1.2'] ];
  }

  rvm_gem {
    'pry':
      ensure       => 'latest',
      name         => 'pry',
      ruby_version => 'ruby-2.1.2',
      require      => [ Class['rvm'], Rvm_system_ruby['ruby-2.1.2'] ];
  }

  rvm_gem {
    'aws-sdk':
      ensure       => '1.61.0',
      name         => 'aws-sdk',
      ruby_version => 'ruby-2.1.2',
      require      => [ Class['rvm'], Rvm_system_ruby['ruby-2.1.2'] ];
  }
}
