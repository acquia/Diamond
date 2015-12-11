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

FROM centos:7
MAINTAINER Acquia Engineering <engineering@acquia.com>

ADD resources/td.repo /etc/yum.repos.d/td.repo

# Install fluentd from RPM package as td-agent which represents stable version
# of fluentd recommended for enterprise environment use
# @see http://docs.fluentd.org/articles/install-by-rpm
RUN yum install -y td-agent && \
  td-agent-gem install fluent-plugin-kinesis && \
  yum clean all && \
  rm -rf /tmp/*

ADD resources/td-agent.conf /etc/td-agent/td-agent.conf

EXPOSE 24224

CMD ["/usr/sbin/td-agent", "-c", "/etc/td-agent/td-agent.conf"]
