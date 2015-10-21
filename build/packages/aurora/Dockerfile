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

FROM acquia/deb_packaging

RUN apt-get update && apt-get install -y \
  wget \
  bison \
  libapr1-dev \
  libcurl4-openssl-dev \
  libsvn-dev \
  python-all-dev

# Install Java
RUN add-apt-repository ppa:openjdk-r/ppa -y && \
  apt-get update && apt-get install -y openjdk-8-jdk

# Install Gradle
RUN mkdir -p /tmp/gradle-packaging && \
  curl -sSL https://github.com/benley/gradle-packaging/archive/master.tar.gz | tar -xz --strip 1 -C /tmp/gradle-packaging && \
  cd /tmp/gradle-packaging && \
  ./gradle-mkdeb.sh 2.7 && \
  dpkg -i gradle*.deb

# Install Thrift
RUN curl -sSL http://people.apache.org/~jfarrell/thrift/0.9.1/contrib/deb/ubuntu/12.04/thrift-compiler_0.9.1_amd64.deb -O && \
  dpkg -i thrift-compiler_*_amd64.deb && \
  rm -f thrift-compiler_*_amd64.deb

ADD resources/package.sh $HOME/package.sh
run chmod +x $HOME/package.sh

WORKDIR $HOME
CMD ./package.sh
