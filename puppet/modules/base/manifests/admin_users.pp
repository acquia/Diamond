class base::admin_users {

  # Remove the default Ubuntu user
  user { 'ubuntu':
    ensure => absent,
  }

  user { 'dnorris':
    ensure     => present,
    name       => 'dnorris',
    managehome => true,
    groups     => ['sudo'],
    shell      => '/bin/bash',
  }

  ssh_authorized_key { 'dnorris':
    ensure => present,
    user   => 'dnorris',
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDEbn7D7RCrLXSE104MphsPZNFoviq50H0YQsisbe89XXSz3UvTlw9M2Ng1an+v0glZqV7klMNFfct+1NiMlz3ZSB5VKH0mhokvaNjhEJ2WrIPoO2asy/AsouFofcUk0A64n3m+kaOmPvrw7iqOzPz0cAk6BdQx9nFa1E06BFCZ+L49VKOzZloOon1oDFyAPybWWP1ZtmR/yHHiu/YwKW5keytTF1Fwx21wK4jxDg6ifpEM1xpPttXt5FkbA6KF3SJuSuLUq743ayTe292MTSWEA37u/6YA11nOVIoNBtt1CBug0qT5+LZ8ze7hRs3xkwTG+DG4QExUulEYaR8bqFu/iTHHs27QqBfaqq04bxQhS9yaBE7Yvz9GCJMLVnBaG0TsaOMD4zj0THuf/crDSu73I77Q8m78CGG7r4A7bB8zvOXHLi5hr/IMnsWPGdMM7cyhBgzSD57pHzsKD0UfN5/kPSBz9D0EXDVlxcDS+xolyUVjETtN7woJYwbMIcfqnYjQzn4JOvcoIpwUVeaDRu3rj46cPLSULj6B2SP3feklnn18Gyco61IHZaJUw6YUWrp+6mUMgmee5/x5O1AQvrzRTOxugEgEyVFS9Fmkcnp1wk6YtwpJK0cUQwnUioDSBWawxWmDApSphBiRDzxBVD+xez66jxjkEx+SPdxpYgGuMQ==',
  }

  user { 'jfarrell':
    ensure     => present,
    name       => 'jfarrell',
    managehome => true,
    groups     => ['sudo'],
    shell      => '/bin/bash',
  }

  ssh_authorized_key { 'jfarrell':
    ensure => present,
    user   => 'jfarrell',
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQD4uJTyh9XtCRO2ALLcZmTIT9cS4hF9SPlvwnmWtwAzjg49Oe1dlGsm+r4RzLAU1ylEofDY/gYTy9Yk9CeLMRjsUJMAnhHDqcgYkYU/JBApO80aadVmUC4mkod+OcNPOlyo385znenaalZcriuNDGWq/7aCZaNeIaaz9BcFMTaYoMfcUcbxsQgHi0UA+WqX86J+u5PMIKY6TIBAA4pzsajA43kT+WF3kF05ELMuez6XEVIFZT39Tqa7sHDNhYuhQO8tpD8YwM5Ex+djxeC7UoTXv9AOwy18JVJ9nYuo+pyfItOrvcwkJf/xiP/9tfBeuBavOhAQ926JkRaTIDBxXt2iaVlbfwxbLj8wSHN882pzRGKUhyKBizu5bJzDFQmmHhI6ecapbiGHp1enRiLhwmP8SyITRoYAqyyyOKOkQQDn0IYPuLhtYRJFTblol1UD/aGvO3qG4btI62zQF8bBR3mj/0tVllcziMEoSmM+jm0fRqfFvOWoA0sbq5/5+ASJkFd4IafzciUXHlbw3dFI1EL+u4ji7EJ4+1BYVPc2uG5Im59ZkYVn6rDNp0uGKGJlDZfvTnLRm1avsEZJsBAaAr08bNw/7L/fYTDmbUDL5RvUbQAxfZvP+jVRnNfwUT88RlZgjm/D6kF8ZtayalU2ZibvH9rb5zXDe4l4N9SWogF4FQ==',
  }

  user { 'ksirineni':
    ensure     => present,
    name       => 'ksirineni',
    managehome => true,
    groups     => ['sudo'],
    shell      => '/bin/bash',
  }

  ssh_authorized_key { 'ksirineni':
    ensure => present,
    user   => 'ksirineni',
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDCvL/bT2+9udL+LhdgFqZHq0lOZiC6z0DC/nmtiJIDLYSP711fiKsl+/iqk3VV4gImawobaoDnpL504Mk5gUkbxdYk7HntVudBPHlg7vACsN8NV/14H7SL0v8ObAKiP4b0lmPqmovFTpfIG2SqcV/Fak3OordX+0X/c19BYQ1kYscRhUyFbRLtWLgfYV5omUjDmZle+V3MvREHFDmQzy3gAsYp5MyGxAg9VZXnGviWv2/hV9/UsbbtHWxg4MFnU1x3BC2Mg4AQtRKG6mIneeNSEL7PMzoi/mLntTTxITyevSxJnoBN0vXK7CxbnfUKyzLL9xduPF9Fr1cp1159iyGy49M6gcC/nzdgLQUhLpeELxAqmV9ZrlWenw+ygqg4NY3riwUH82wTWRqwweI7Cj5ti9hssyFGbUzU/lwKNq82iXEMeEvkVbaSNCsz/JPSqOv7EKDCxnMoTF6VU9WMxt7AyPKezyk8OuA0gXYccrNO8Lzi8jz4GYx9/MJa710XvvQ5huQ6IEPXRBNI/HBkDOw4PwyoWqOEPiCkmeBphpDdz3zH4BVm55hR066N5zBvM8QIHSqDROmP3BrjSAr+Ff4Gow95pMX+kvi8eb0SYr0/VQCsCtd7FPxyNmxEYKKqQOPth4hcsip/C6QsdCLJ26PDpKD/FR5v/xSMGsLMZmInyw==',
  }

  user { 'khankens':
    ensure     => present,
    name       => 'khankens',
    managehome => true,
    groups     => ['sudo'],
    shell      => '/bin/bash',
  }

  ssh_authorized_key { 'khankens':
    ensure => present,
    user   => 'khankens',
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDVr8lO/6OeG5d/6+nNMo53Mim8E5am0RSHj+BcddUgXkLid4PfOVeBzQWYOBcbJPBXXxtLX+uR+ynTyg0pIrdctoQ1Dy+9xixN3YNCT/j2veKXTCq8C9vJVm+51YNYKg2IHaMMH0d4jWE8b3iI8q159qUyxL2BBljOaKSKUBkZI0+ID8WCgHt5snH/3IbesIoHnj+BuuKgkvl7oRg8KX9TR8C6rZLFnVqdkxYdkrbuar+1tRaPYu4ZZrGLYzv6itRf8xhx+lBPv4RTHWCoPlAc0ayWeilY/MaFxZMzpmeS2djFjJ2jJvKYt7oBR/UACfaoxNd0/EALlbuDbmdtoMUDYOlBm1xPionJYke4TvgYCrhY/jK4twr73iPRDLysU9c9TidUlL6Jz5KO71rPPW2SaTGFo9KkXCN2LCnSAVFStRjxmUUVQRoq7tG30psZ1D9trUwdi6MY0KJuMtmBxM3bp5fRaiGBL8xT6NOqx3zQzkWXM3dKaABcE/iD9m6MFnih8H9HdmjJOohj6+0Qcjrd6dKDRdAECWMMTVUOe8sVr8zZlo+xoNkJerB2xmYpmHTe0lnZsbJeLup5mEYra/GNt6L9x9sdRwC/u3PRFFqeI32PiHwrYYpt25/4+QAF6YmUOOIsMJvhH3UHAwnORap5F2fqd7faT+BOETT4+pguaQ==',
  }
}
