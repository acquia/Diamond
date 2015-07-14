# The $jenkins_plugin_username is a fact defined in the spec file.
class { 'acquia_jenkins':
  plugin_username => $jenkins_plugin_username
}
