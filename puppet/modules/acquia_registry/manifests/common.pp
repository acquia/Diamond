# Copyright 2015 Acquia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class acquia_registry::common {
  file { '/etc/docker':
    ensure => directory,
  }

  file { '/etc/docker/certs.d':
    ensure  => directory,
    require => File['/etc/docker'],
  }

  file { "/etc/docker/certs.d/${registry_endpoint}/ca.crt":
    ensure  => 'link',
    target  => '/etc/pki/tls/certs/ca-bundle.crt',
    require => File['/etc/docker/certs.d'],
  }

  if $registry_endpoint {
    file { "/etc/docker/certs.d/${registry_endpoint}":
      ensure  => directory,
      require => File['/etc/docker/certs.d'],
    }

    file { "/etc/docker/certs.d/${registry_endpoint}/domain.crt":
      ensure  => present,
      content => "${registry_ssl_certificate}",
      require => File["/etc/docker/certs.d/${registry_endpoint}"],
    }
  }
}
