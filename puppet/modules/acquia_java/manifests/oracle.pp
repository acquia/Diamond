class acquia_java::oracle (
  $ensure  = 'present',
  $version = '8',
  $javaSE  = 'jdk',
  $baseUrl = 'http://download.oracle.com/otn-pub/java/jdk/',
) {
  # Validate Java SE package type to download
  if $javaSE !~ /(jre|jdk)/ {
    fail('javaSE must be either jre or jdk.')
  }

  # Determine Oracle Java major, minor and build version
  case $version {
    '8' : {
      $releaseMajor = '8'
      $releaseMinor = '66'
      $releaseBuild = '17'
    }
    default : {
      $releaseVersionArray = split($version, '-')
      $releaseVersion = split($releaseVersionArray[0], 'u')

      $releaseMajor = $releaseVersion[0]
      $releaseMinor = $releaseVersion[1]
      $releaseBuild = $releaseVersionArray[1]
    }
  }

  $packageName = "${javaSE}-${releaseMajor}u${releaseMinor}-linux-x64.rpm"

  # Install Oracle Java
  case $ensure {
    'present' : {
      exec { "Download Oracle JavaSE ${javaSE} ${version}" :
        command => "/bin/curl -sSL -H 'Cookie: oraclelicense=accept-securebackup-cookie' ${baseUrl}/${releaseMajor}u${releaseMinor}-b${releaseBuild}/${packageName} -o /tmp/${packageName}",
        unless  => "/bin/test -d /usr/java/${javaSE}1.${releaseMajor}.0_${releaseMinor}",
      } ->
      exec { "Install Oracle JavaSE ${javaSE} ${version}" :
        command => "/bin/rpm --force -ivh /tmp/${packageName}",
        creates => "/usr/java/${javaSE}1.${releaseMajor}.0_${releaseMinor}",
      }
    }
    'absent' : {
      package { "Install Oracle JavaSE ${javaSE} ${version}":
        ensure => 'absent',
        name   => "${javaSE}1.${releaseMajor}.0_${releaseMinor}",
      }
    }
    default : {
      notice ("Action ${ensure} not supported.")
    }
  }
}
