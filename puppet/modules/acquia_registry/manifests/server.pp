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

class acquia_registry::server {
  include acquia_registry::common

  file { "/etc/docker/certs.d/${registry_endpoint}/domain.key":
    ensure  => present,
    content => "${registry_ssl_key}",
    require => File["/etc/docker/certs.d/${registry_endpoint}"],
  }

  package { 'apache2-utils':
    ensure => present
  }

  exec { 'create-htpasswd':
    command => "/usr/bin/htpasswd -Bbc /etc/docker/certs.d/${registry_endpoint}/htpasswd admin ${registry_admin_password}",
    creates => "/etc/docker/certs.d/${registry_endpoint}/htpasswd",
    require =>  [
                  Package['apache2-utils'],
                  File["/etc/docker/certs.d/${registry_endpoint}"],
                ]
  }

  docker::run { 'registry':
    image           => 'registry:2.1.1',
    ports           => ['0.0.0.0:443:5000'],
    use_name        => true,
    volumes         => ["/etc/docker/certs.d/${registry_endpoint}:/certs"],
    env             =>  [
                          'REGISTRY_STORAGE=s3',
                          'REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt',
                          'REGISTRY_HTTP_TLS_KEY=/certs/domain.key',
                          'REGISTRY_STORAGE_PATH=registry',
                          'REGISTRY_AUTH=htpasswd',
                          'REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm"',
                          'REGISTRY_AUTH_HTPASSWD_PATH=/certs/htpasswd',
                          'REGISTRY_STORAGE_S3_ENCRYPT=true',
                          'REGISTRY_STORAGE_S3_SECURE=true',
                          "REGISTRY_STORAGE_S3_REGION=${registry_storage_region}",
                          "REGISTRY_STORAGE_S3_BUCKET=${registry_storage_bucket}",
                        ],
    restart_service => true,
    privileged      => false,
    pull_on_start   => true,
    require         =>  [
                          File["/etc/docker/certs.d/${registry_endpoint}/domain.key"],
                          Exec['create-htpasswd'],
                        ],
  }
}
