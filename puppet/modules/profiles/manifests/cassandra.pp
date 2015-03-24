class profiles::cassandra {
  contain profiles::java
  include ::cassandra

  Class['profiles::java'] -> Class['::cassandra']
}
