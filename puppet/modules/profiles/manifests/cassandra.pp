class profiles::cassandra {
  contain profiles::java
  include ::cassandra
}
