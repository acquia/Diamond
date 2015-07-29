class profiles::java {
  include profiles::base
  include apt
  contain ::java
}
