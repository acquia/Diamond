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

ENV GOROOT /usr/lib/go
ENV GOPATH /usr/share/go
ENV PATH ${GOROOT}/bin:${GOPATH}/bin:$PATH

RUN mkdir -p /usr/share/go \
  # Install dependencies
  && yum install -y \
    gcc \
    git \
    make \

  # Install go
  && curl -sSL https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz | tar -C /usr/lib/ -xz \

  # Clean up
  && yum clean all \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*
