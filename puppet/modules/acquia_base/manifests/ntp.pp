class acquia_base::ntp {
  class { '::ntp':
    servers => [
      'tock.usno.navy.mil',
      'bonehed.lcs.mit.edu',
      'nist.netservicesgroup.com',
      'gps.layer42.net'
    ],
  }
}