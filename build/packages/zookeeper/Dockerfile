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

FROM acquia/rpm_packaging

ENV JAVA_HOME /usr/java/jdk1.7.0_79
ENV M2_HOME /usr/java/maven
ENV ANT_HOME /usr/java/ant
ENV PATH $PATH:${JAVA_HOME}/bin:${M2_HOME}/bin:${ANT_HOME}/bin

ADD resources/package.sh $HOME/package.sh

RUN chmod +x $HOME/package.sh \
  # Install Java
  && curl --retry 5 -H 'Cookie: oraclelicense=accept-securebackup-cookie' -OJ -sSL http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm \
  && rpm -ivh jdk-7u79-linux-x64.rpm \
  && rm jdk-7u79-linux-x64.rpm \

  # Install Maven
  && mkdir -p /usr/java/maven \
  && curl --retry 5 -sSL https://dist.apache.org/repos/dist/release/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz | tar xz --strip 1 -C /usr/java/maven \

  # Install Ant
  && mkdir -p /usr/java/ant \
  && curl --retry 5 -sSL https://dist.apache.org/repos/dist/release/ant/binaries/apache-ant-1.9.6-bin.tar.gz | tar -xz --strip 1 -C /usr/java/ant \

  # Clean up
  && yum clean all \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*

WORKDIR $HOME
CMD ./package.sh
