class graphite {
  include apt
  require graphite::packages
  require graphite::apache
  require graphite::config
}
