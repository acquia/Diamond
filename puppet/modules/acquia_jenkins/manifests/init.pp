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
  $version = 'latest',
  $plugin_username = 'jenkins'
){
  docker::image { 'acquia/grid-ci':
    ensure    => 'latest',
    image     => "${private_docker_registry}acquia/gridci",
    image_tag => "${version}",
  }

  docker::run { 'grid-ci':
    image           => "${private_docker_registry}acquia/gridci:${version}",
    expose          => [ '8080' ],
    ports           => [ '80:8080' ],
    detach          => false,
    restart_service => true,
    env             => [
      "AWS_REGION=${aws_region}",
      "AMI_NAME=${jenkins_default_ami}",
      'EC2_KEYPAIR_NAME=acquia-grid',
      "GITHUB_OAUTH_TOKEN=${jenkins_github_oauth_key}",
      "GITHUB_CLIENT_ID=${jenkins_github_client_id}",
      "GITHUB_CLIENT_SECRET=${jenkins_github_client_secret}",
      "STAGE=${stage}",
      "ZK_UI_PASSWORD=${jenkins_zk_ui_password}",
      "NEMESIS_SECRET_KEY=${nemesis_secret_key}",
    ],
    volumes         => [
      '/var/jenkins:/var/jenkins_home',
      '/var/run/docker.sock:/run/docker.sock',
    ],
    require         => [
      Docker::Image['acquia/grid-ci']
    ]
  }
}
