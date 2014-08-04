class base::repos {
  include apt

  $stack_name = cloudformation_stackname(@ec2_instance_id)

  apt::source { 'nemesis':
    location    => cloudformation_output(@stack_name, 'AptMirrorURL'),
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '23406CA7',
    key_server  => 'pgp.mit.edu',
    include_src => false,
  }
}
