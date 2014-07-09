class diamond::packages {
  include python

  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
  }
}
