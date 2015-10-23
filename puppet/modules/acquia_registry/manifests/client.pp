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

class acquia_registry::client(
  $local_user = 'root'
) {
  include acquia_registry::common

  if $registry_endpoint {
    docker::registry { $registry_endpoint:
      username   => 'admin',
      password   => "${registry_admin_password}",
      email      => 'engineering@acquia.com',
      local_user => $local_user,
      require    => File["/etc/docker/certs.d/${registry_endpoint}/domain.crt"],
    }
  }
}
