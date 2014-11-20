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

RUN apt-get update -y && apt-get dist-upgrade -y

# Install default packages
RUN apt-get install -y build-essential pkg-config git curl \
                       libtool libpcre3-dev libreadline-dev \
                       dh-make debhelper cdbs python-support \
                       ruby ruby-dev \
                       python-virtualenv python-pip python-dev \
                       golang golang-go mercurial

# Ruby Gems
RUN echo 'gem: --no-rdoc --no-ri' >> /etc/gemrc && \
      gem install aws-sdk fpm pry

# Add default known_hosts
RUN mkdir -p $HOME/.ssh && \
      ssh-keyscan github.com >> $HOME/.ssh/known_hosts && \
      chmod -R 600 $HOME/.ssh

# Clean up
RUN apt-get clean && \
      rm -rf /var/cache/apt/* && \
      rm -rf /var/lib/apt/lists/* && \
      rm -rf /tmp/* && \
      rm -rf /var/tmp/*

WORKDIR $HOME