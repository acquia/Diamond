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

class profiles::mesos {
  contain profiles::java
  include ::acquia_mesos
  include aurora::params

  # This gets around the fact that you can't merge data using
  # automated parameter lookup in hiera
  # Ideally the puppet-aurora class would have a better mechanism for handling
  # this
  $opts = hiera('aurora::options', {})
  $hash = merge($aurora::params::scheduler_options, $opts)

  class { 'aurora':
    version           => hiera('aurora::version'),
    configure_repo    => hiera('aurora::configure_repo'),
    manage_package    => hiera('aurora::manage_package'),
    master            => $::mesos_master,
    scheduler_options => $hash,
  }

  Class['profiles::java'] ->
  Class['::acquia_mesos'] ->
  Class['aurora']
}
