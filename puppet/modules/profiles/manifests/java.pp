class profiles::java {
  # There's a possible dependency cycle here if you use contain
  # Leaving these as includes gets around it as long as you use the contain
  # function to include the Java class in any profile the requires it
  include profiles::base
  include ::java
}
