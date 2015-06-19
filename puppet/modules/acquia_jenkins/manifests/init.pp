class acquia_jenkins {

  include jenkins

  jenkins::plugin { 'parameterized-trigger': }

  jenkins::plugin { 'token-macro': }

  jenkins::plugin { 'mailer': }

  jenkins::plugin { 'scm-api': }

  jenkins::plugin { 'promoted-builds': }

  jenkins::plugin { 'matrix-project': }

  jenkins::plugin { 'git-client': }

  jenkins::plugin { 'ssh-credentials': }

  jenkins::plugin { 'credentials': }

  jenkins::plugin { 'git': }

  jenkins::user { 'darwin':
    email    => 'darwin@acquia.com',
    password => '$::jenkins_password',
  }

}
