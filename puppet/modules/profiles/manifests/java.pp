class profiles::java {
  contain profiles::base
  include ::java

  Class['profiles::base'] -> Class['::java']
}
