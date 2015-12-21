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

FROM centos:7

ENV HOME /root

RUN yum install -y \
  autoconf \
  automake \
  binutils \
  bison \
  createrepo \
  flex \
  gcc \
  gcc-c++ \
  libtool \
  libffi-devel \
  make \
  openssh-clients \
  patch \
  pkgconfig \
  ruby-devel \
  rpm-build \
  rpm-sign \
  tar \
  unzip \
  which \
  zlib-devel \

  # Clean up
  && yum clean all \
  && rm -rf /tmp/*

ADD resources/.rpmmacros $HOME/.rpmmacros

RUN mkdir -p $HOME/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

RUN mkdir -p $HOME/.ssh && \
  ssh-keyscan github.com >> $HOME/.ssh/known_hosts && \
  chmod -R 600 $HOME/.ssh

RUN echo 'gem: --no-rdoc --no-ri' >> /etc/gemrc && \
  gem install bundler fpm

WORKDIR $HOME/rpmbuild
CMD ["/bin/bash"]
