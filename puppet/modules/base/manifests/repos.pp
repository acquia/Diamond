class base::repos {
  include apt

  # TODO This needs to be here to mantain a consistent state. Figure out how to make it work.
  #$stack_name = cloudformation_stackname($ec2_instance_id)

  #apt::source { 'nemesis':
  #  location    => cloudformation_output($stack_name, 'AptMirrorURL'),
  #  release     => $::lsbdistcodename,
  #  repos       => 'main',
  #  key         => '23406CA7',
  #  key_server  => 'pgp.mit.edu',
  #  include_src => false,
  #}

  apt::ppa { "ppa:webupd8team/java": }
}
