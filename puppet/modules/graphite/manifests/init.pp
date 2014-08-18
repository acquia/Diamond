class graphite {
  include apt
  require graphite::apache
  require graphite::config
}
