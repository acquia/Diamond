class sumologic (
  $credentials = undef,
  $paths = undef,
  $category = undef,
){
  include java

  if $::acquia_sumologic {
    include sumologic::install
    Class['java'] -> Class['sumologic::install']
  }
  else {
    include sumologic::uninstall
  }
}
