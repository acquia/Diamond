class profiles::sumologic {
  contain profiles::java
  include ::sumologic

  Class['profiles::java'] -> Class['::sumologic']
}
