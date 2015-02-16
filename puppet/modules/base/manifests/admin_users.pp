class base::admin_users {

  define admin_user ($user = $title, $ssh_key, $ssh_key_type = 'ssh-rsa') {
    user { $user:
      ensure      => present,
      name        => $user,
      managehome  => true,
      groups      => ['sudo'],
      shell       => '/bin/bash'
    }

    ssh_authorized_key { $user:
      ensure  => present,
      user    => $user,
      type    => $ssh_key_type,
      key     => $ssh_key
    }
  }

  # Remove the default Ubuntu user
  user { 'ubuntu':
    ensure => absent,
  }

  admin_user { 'dnorris': ssh_key => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDEbn7D7RCrLXSE104MphsPZNFoviq50H0YQsisbe89XXSz3UvTlw9M2Ng1an+v0glZqV7klMNFfct+1NiMlz3ZSB5VKH0mhokvaNjhEJ2WrIPoO2asy/AsouFofcUk0A64n3m+kaOmPvrw7iqOzPz0cAk6BdQx9nFa1E06BFCZ+L49VKOzZloOon1oDFyAPybWWP1ZtmR/yHHiu/YwKW5keytTF1Fwx21wK4jxDg6ifpEM1xpPttXt5FkbA6KF3SJuSuLUq743ayTe292MTSWEA37u/6YA11nOVIoNBtt1CBug0qT5+LZ8ze7hRs3xkwTG+DG4QExUulEYaR8bqFu/iTHHs27QqBfaqq04bxQhS9yaBE7Yvz9GCJMLVnBaG0TsaOMD4zj0THuf/crDSu73I77Q8m78CGG7r4A7bB8zvOXHLi5hr/IMnsWPGdMM7cyhBgzSD57pHzsKD0UfN5/kPSBz9D0EXDVlxcDS+xolyUVjETtN7woJYwbMIcfqnYjQzn4JOvcoIpwUVeaDRu3rj46cPLSULj6B2SP3feklnn18Gyco61IHZaJUw6YUWrp+6mUMgmee5/x5O1AQvrzRTOxugEgEyVFS9Fmkcnp1wk6YtwpJK0cUQwnUioDSBWawxWmDApSphBiRDzxBVD+xez66jxjkEx+SPdxpYgGuMQ==' }

  admin_user { 'jfarrell': ssh_key => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQD4uJTyh9XtCRO2ALLcZmTIT9cS4hF9SPlvwnmWtwAzjg49Oe1dlGsm+r4RzLAU1ylEofDY/gYTy9Yk9CeLMRjsUJMAnhHDqcgYkYU/JBApO80aadVmUC4mkod+OcNPOlyo385znenaalZcriuNDGWq/7aCZaNeIaaz9BcFMTaYoMfcUcbxsQgHi0UA+WqX86J+u5PMIKY6TIBAA4pzsajA43kT+WF3kF05ELMuez6XEVIFZT39Tqa7sHDNhYuhQO8tpD8YwM5Ex+djxeC7UoTXv9AOwy18JVJ9nYuo+pyfItOrvcwkJf/xiP/9tfBeuBavOhAQ926JkRaTIDBxXt2iaVlbfwxbLj8wSHN882pzRGKUhyKBizu5bJzDFQmmHhI6ecapbiGHp1enRiLhwmP8SyITRoYAqyyyOKOkQQDn0IYPuLhtYRJFTblol1UD/aGvO3qG4btI62zQF8bBR3mj/0tVllcziMEoSmM+jm0fRqfFvOWoA0sbq5/5+ASJkFd4IafzciUXHlbw3dFI1EL+u4ji7EJ4+1BYVPc2uG5Im59ZkYVn6rDNp0uGKGJlDZfvTnLRm1avsEZJsBAaAr08bNw/7L/fYTDmbUDL5RvUbQAxfZvP+jVRnNfwUT88RlZgjm/D6kF8ZtayalU2ZibvH9rb5zXDe4l4N9SWogF4FQ==' }

  admin_user { 'kasisnu': ssh_key => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDJEf3UFVNP68faCfuwacJoee3wUY+PWYvU5hHREVcyh63TeUKovrqKsS5p6dO9tZhOQayXGmM//JJn51m+2IP/cVRCUthDksVHkDQeXONgzgJbuRJT7hIrx0mUGB3QYlO9lQB63T3oNyJof6Ce3GUETDSiWCRah4RrYc/use06vEHQM2JqOOmEHfGocn91qawKV0xTE2wxe67KNlnp1hauoChQVe3FBMnUdYrMYBBvQRE5l33Th0el3+7YJPMz/v3qGRim054Yv3kns28LXANhiDwV9pIWz6+vBg6detyAk0KpKb7FhNsNugalQFdplz1+Hcr7CukUP30X5zqRCjBZ6Jah1sjTi8ee/85Xae6afWJA8TZiiQPfT6mJLGzSHnrBxtmZe356uIg16vbokpKLk4Nkn+BGAjp7nB3WDHwmcBVln14z9M+Wn2XYDbIxdufFKHGgnbr8IwIdveduaxnlAhMiGsud1uhkJAx46mUe/bOsri8KEhESRAS8vCLouVERxtsXAUIFzjX97QSkh2Be5Rr1Z1MuHqNNMEHOj51Dlsut1yjoslBrCG93LoTMJ8H6Hm4MjV6r9djWj6gH/KICziPa87z1DSutjKaw9C//H00pVUA6x5lqaydA8J4whNz79hS++OnSt2oMnA4yCKBO0UHVVvEWqfeqg0mA+XPYTQ==' }

  admin_user { 'khankens': ssh_key => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDVr8lO/6OeG5d/6+nNMo53Mim8E5am0RSHj+BcddUgXkLid4PfOVeBzQWYOBcbJPBXXxtLX+uR+ynTyg0pIrdctoQ1Dy+9xixN3YNCT/j2veKXTCq8C9vJVm+51YNYKg2IHaMMH0d4jWE8b3iI8q159qUyxL2BBljOaKSKUBkZI0+ID8WCgHt5snH/3IbesIoHnj+BuuKgkvl7oRg8KX9TR8C6rZLFnVqdkxYdkrbuar+1tRaPYu4ZZrGLYzv6itRf8xhx+lBPv4RTHWCoPlAc0ayWeilY/MaFxZMzpmeS2djFjJ2jJvKYt7oBR/UACfaoxNd0/EALlbuDbmdtoMUDYOlBm1xPionJYke4TvgYCrhY/jK4twr73iPRDLysU9c9TidUlL6Jz5KO71rPPW2SaTGFo9KkXCN2LCnSAVFStRjxmUUVQRoq7tG30psZ1D9trUwdi6MY0KJuMtmBxM3bp5fRaiGBL8xT6NOqx3zQzkWXM3dKaABcE/iD9m6MFnih8H9HdmjJOohj6+0Qcjrd6dKDRdAECWMMTVUOe8sVr8zZlo+xoNkJerB2xmYpmHTe0lnZsbJeLup5mEYra/GNt6L9x9sdRwC/u3PRFFqeI32PiHwrYYpt25/4+QAF6YmUOOIsMJvhH3UHAwnORap5F2fqd7faT+BOETT4+pguaQ==' }

  admin_user { 'msonnabaum': ssh_key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAyLvp8BrAncsxw1pbtDdQQMiWgHHO5MR9VRAhUTt1T/AOJWAGap0FYXQW3FCeaJNDi4HHnP5yKOXBlbrFCTC64UiTwba30KhZ8rDadivrwCkadcyxq/rwtbH4ti+pqG3GZBVdLFs2JtSFjZXE+9X0TxeKujEjGNtRcYbgNkI4HgXkpHrynKWkNzNsuBDkzBdnb5dZ1nfBz9sUwXzNm9wsSGUD/Sh9N6R01ZaY+FO10WH3cFIs36gV34t6GbtE4+U5cdl9dKY0lOYM5ZPbPD82yJmTXe6qWA9iJEA262ofEvo/JPzGggNM6kgZMukxiUOvZw+EF5IxUyuvgd2TEI6CvQ==' }

  admin_user { 'pimvanderwal': ssh_key => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAlTTDohwyY3fqDBnax613RcQX/A1b8bajw53Kt5oN/dtjV9P0qkbwKKwoQce8gGA/A9rwHmO70/kEBf+EN/t8C7QKTqViwY7hvWX6gp8OB4VqeUrSb1XIl2UZV8IGb5SaRQ98jxkE2pfm1TLW86qJ0yxW63QYXXUNj0E6Sfw7T7GSjF94a0bm4TwhDqFnpe1Nv7hw/gigWldoIKrR/WG9w2hwtN6lROuW0SUcYTMoRgZBg6t2AuIWOsdb8AlS0VPdOh+bK3QRI9/dr0N7rx8xG5Nr7IcRN8dD4DYN+P+T99VAkmKszVDlCmdXMl/bIEGZUZl/6DR/VTEXPYITea8n+qbag8Pyc2FOQ+NO31Lt6fyJgGnGQTcXT0H24f3PNosb65gOo/fquEAVowg8uHD6DbipyzC2rinokvY5LAaxp+DHWsJAlnD29jrwjzPyesP6yv/SKGBKp4XSZAjDhwhTNiXiAaNoqP3uEdWeWLawRWp7ky8o70Ne1O6Dq/pomzaLSe72bZMAVVP2A1z5EUizJe57h3vbvzPZO14eze4ayL1L6gILrnxLCjhvvl4E2mLEqOF5Y7dfDDpupCAo7z8+AryrejXXyWOMqNu10NNs1OM6vCBDkAYPFTbaB/6BRJsBWmQnbgg+5cTX3u5FjPgJ2Nqwf9xONxFSgH9Ey0kIcq0=' }

  admin_user { 'pingram': ssh_key => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrezvGa0uAMjNRgZmSGLoHGesD4FSTAO5Ty/UbiqVEnnth7oPn6tdIp65B581abs6z7MYZkpsWDdJihYioKGvy3PBEnGuQyoztTpf4tHX4Xah8AEnL3zpcH8dWAUqD6Tfmti3mUNDWIRGpovqrRMvXdlKU8RN8XVpFJn8/9k4MtCa9ubZ6H/fK32uFgwbV5TAtNozswnTt4Mb46Qho/UcTfrrMn6Pa13pOwfqoCE10SEf1ck8aX+WMD1NlJBpeYwYyBFaLWBb2fSSsRMtaWJ8PbP20tEElArsoi8bGucDg2SRZ+J7sedPkdWg762jvey60qBYpZGuSZZor1F6HGhV5' }

  #admin_user { '': ssh_key => '' }
}
