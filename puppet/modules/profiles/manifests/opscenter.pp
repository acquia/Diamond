class profiles::opscenter {
  contain profiles::base
  contain profiles::java
  include cassandra::opscenter

  Class['profiles::base'] -> Class['cassandra::opscenter']
}
