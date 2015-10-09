# Class: acquia_jenkins
#
# This module manages our build of jenkins ci.
#
# Parameters:
#
#  [*plugin_username*]
#    This specifies the unix user used to install the jenkins plugins. Normally
#    this will be the jenkins user, but for cases such as testing. This user
#    can be altered.
#
class acquia_jenkins (
  $plugin_username = 'jenkins'
) {
  package { 'bundler':
    ensure => present,
  }

  # We set up the jenkins user and group ourselves before installing jenkins.
  # This is to ensure that we can add it to the docker group.
  group { 'jenkins':
    ensure => 'present',
  }

  user { 'jenkins':
    require    => Group['jenkins'],
    name       => 'jenkins',
    groups     => [ 'jenkins', 'docker' ],
    home       => '/var/lib/jenkins',
    managehome => false,
    comment    => 'Managed by Puppet',
    shell      => '/bin/bash',
    password   => '!',
  }

  file { '/mnt/acquia_grid_ci_workspace':
    ensure  => directory,
    require => User['jenkins'],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file { '/mnt/acquia_grid_ci_dist':
    ensure  => directory,
    require => User['jenkins'],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file { '/var/lib/jenkins':
    ensure  => directory,
    require => User['jenkins'],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file { '/var/lib/jenkins/.ssh':
    ensure  => directory,
    require => [
      User['jenkins'],
      File['/var/lib/jenkins']
    ],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file { '/var/lib/jenkins/.ssh/config':
    ensure  => directory,
    require => File['/var/lib/jenkins/.ssh'],
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    source  => 'puppet:///modules/acquia_jenkins/jenkins_ssh_config',
  }

  file { '/var/lib/jenkins/.ssh/github.pub':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    source  => 'puppet:///modules/acquia_jenkins/github.pub',
    require => File['/var/lib/jenkins/.ssh'],
  }

  file { '/var/lib/jenkins/users':
    ensure  => directory,
    require => [
      User['jenkins'],
      File['/var/lib/jenkins']
    ],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file { '/var/lib/jenkins/users/admin':
    ensure  => directory,
    require => [
      User['jenkins'],
      File['/var/lib/jenkins']
    ],
    owner   => 'jenkins',
    group   => 'jenkins',
  }

  file { '/var/lib/jenkins/config.xml':
    require => [
      User['jenkins'],
      File['/var/lib/jenkins'],
    ],
    owner   => 'jenkins',
    group   => 'jenkins',
    source  => 'puppet:///modules/acquia_jenkins/config.xml',
    mode    => '0644',
  }

  file { '/var/lib/jenkins/users/admin/config.xml':
    require => [
      User['jenkins'],
      File['/var/lib/jenkins']
    ],
    owner   => 'jenkins',
    group   => 'jenkins',
    content => template('acquia_jenkins/user-admin-config.xml.erb'),
    mode    => '0644',
  }

  # Verify that the ssh key was deployed. This is to ensure the correct
  # ordering before executing jenkins cli commands.
  exec { 'create-jenkins-cli-key':
    require => File['/var/lib/jenkins/.ssh'],
    command => 'test -f /var/lib/jenkins/.ssh/jenkins_cli',
    path    => '/usr/bin',
  }

  class { 'jenkins':
    require         => [
      Exec['create-jenkins-cli-key'],
      File['/var/lib/jenkins/config.xml'],
      File['/var/lib/jenkins/users/admin/config.xml'],
      User['jenkins'],
    ],
    cli             => true,
    cli_ssh_keyfile => '/var/lib/jenkins/.ssh/jenkins_cli',
    install_java    => false,
    lts             => true,
  }

  class { 'jenkins::cli_helper':
    ssh_keyfile => '/var/lib/jenkins/.ssh/jenkins_cli',
  }

  $jenkins_plugins = [
                      'build-token-root',
                      'credentials',
                      'plain-credentials',
                      'credentials-binding',
                      'docker-build-publish',
                      'authentication-tokens',
                      'docker-commons',
                      'node-iterator-api',
                      'ec2',
                      'git',
                      'git-client',
                      'git-server',
                      'google-login',
                      'mailer',
                      'matrix-project',
                      'parameterized-trigger',
                      'promoted-builds',
                      'rebuild',
                      'scm-api',
                      'ssh-agent',
                      'ssh-credentials',
                      'token-macro',
                      'groovy',
                      'mapdb-api',
                      'workflow-cps-global-lib',
                      'workflow-durable-task-step',
                      'workflow-step-api',
                      'workflow-cps',
                      'workflow-scm-step',
                      'workflow-job',
                      'workflow-basic-steps',
                      'workflow-api',
                      'durable-task',
                      'workflow-support',
                      'script-security',
                      'ci-skip',
                      'ruby-runtime',
                      'greenballs',
                      ]

  # Install plugins
  jenkins::plugin { $jenkins_plugins:
    username => "${plugin_username}"
  }

  jenkins::plugin { 'workflow-aggregator':
    username => "${plugin_username}",
    require  => [
                  Jenkins::Plugin['workflow-cps-global-lib'],
                  Jenkins::Plugin['workflow-durable-task-step'],
                  Jenkins::Plugin['workflow-step-api'],
                  Jenkins::Plugin['workflow-scm-step'],
                  Jenkins::Plugin['workflow-job'],
                  Jenkins::Plugin['workflow-basic-steps'],
                  Jenkins::Plugin['workflow-api'],
                  Jenkins::Plugin['durable-task'],
                  Jenkins::Plugin['workflow-support']
                ],
  }

  file { '/opt/grid-ci':
    ensure  => 'directory',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    require => User['jenkins'],
  }

  vcsrepo { '/opt/grid-ci':
    ensure   => present,
    provider => git,
    source   => 'git@github.com:kasisnu/grid-ci',
    revision => 'baseimage',
    user     => 'jenkins',
    require  => [
                  File['/var/lib/jenkins/.ssh/github.pub'],
                  File['/opt/grid-ci'],
                  User['jenkins'],
                ],
  }

  file { '/var/lib/jenkins/jobs':
    ensure  => symlink,
    target  => '/opt/grid-ci/jobs',
    force   => true,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    require =>  [
                  Vcsrepo['/opt/grid-ci'],
                  User['jenkins'],
                ],
  }

  # After installing the admin user, we need to restart the service in order
  # for the ssh key authentication to work. This is a brute force method
  # because notifying the jenkins service does not work and we cannot reload
  # the configuration via cli since we do not allow anonymous access. The
  # sleep command gives jenkins some time to load before accessing the cli
  # commands. We touch a lock file to ensure that this only happens once.
  $acquia_jenkins_installed = '/var/lib/jenkins/acquia_jenkins_installed'

  exec { 'acquia-jenkins-installed':
    require => [
      Service['jenkins'],
      File['/var/lib/jenkins'],
      File['/var/lib/jenkins/jobs'],
      Exec['create-jenkins-cli-key'],
    ],
    unless  => "test -f ${acquia_jenkins_installed}",
    command => "service jenkins restart && sleep 5 && touch ${acquia_jenkins_installed}",
    path    => '/bin:/usr/bin',
  }

  jenkins::user { 'admin':
    require    => [
      Exec['acquia-jenkins-installed'],
      File[$::jenkins::cli::jar],
      File[$::jenkins::cli_helper::helper_groovy],
      File['/var/lib/jenkins/users/admin/config.xml'],
    ],
    email      => "${::jenkins_email}",
    password   => "${::jenkins_password}",
    public_key => "${::jenkins_cli_pub_key}",
  }

  contain acquia_jenkins::proxy
}
