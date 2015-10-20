# Copyright 2014 Acquia, Inc.
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

FROM ubuntu:trusty

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
  build-essential \
  debhelper \
  dh-make \
  devscripts \
  cdbs \
  python-support \
  curl \
  git \
  unzip \
  software-properties-common \
  python-software-properties \
  ruby \
  ruby-dev \
  zlib1g-dev

RUN mkdir -p $HOME/.ssh && \
  ssh-keyscan github.com >> $HOME/.ssh/known_hosts && \
  chmod -R 600 $HOME/.ssh

RUN echo 'gem: --no-rdoc --no-ri' >> /etc/gemrc && \
  gem install fpm

# Clean up
RUN apt-get clean && \
  rm -rf /var/cache/apt/* && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* && \
  rm -rf /var/tmp/*

WORKDIR $HOME
CMD ["/bin/bash"]

