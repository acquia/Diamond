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

class acquia_mesos::services::api(
  $version = 'latest'
){
  docker::image { 'acquia/grid-api':
    image     => "${registry_endpoint}acquia/grid-api",
    image_tag => "${version}",
    force     => true,
  }

  # Pass logstream name to grid-api so it can launch containers with correctly routed logs
  if $logstream_name {
    $env = [
      "AG_REMOTE_SCHEDULER_HOST=${ec2_public_ipv4}",
      'AG_REMOTE_SCHEDULER_PORT=8081',
      'AG_LOGSTREAM=1',
      'AG_LOGSTREAM_DRIVER=fluentd',
      'AG_LOGSTREAM_DRIVER_OPTS=fluentd-address=0.0.0.0:24224',
      'AG_LOGSTREAM_TAG_PREFIX=grid',
    ]
  } else {
    $env = [
      "AG_REMOTE_SCHEDULER_HOST=${ec2_public_ipv4}",
      'AG_REMOTE_SCHEDULER_PORT=8081',
    ]
  }

  docker::run { 'grid-api':
    image            => "${registry_endpoint}acquia/grid-api:${version}",
    env              => $env,
    ports            => ['2114'],
    expose           => ['2114'],
    restart          => always,
    extra_parameters => [
      '--restart=always',
      '-d',
      '--log-driver=syslog --log-opt syslog-facility=daemon --log-opt tag="grid-api"'
    ],
    privileged       => false,
    require          => [
      Docker::Image['acquia/grid-api'],
    ],
  }
}
