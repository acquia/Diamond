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

FROM centos:centos7

ENV HOME /root

RUN yum install -y \
  createrepo \
  rpm-sign \
&& yum clean all \
&& rm -rf /tmp/*

ADD resources/createrepo.sh /createrepo.sh
ADD resources/sign-rpm-packages.sh /sign-rpm-packages.sh
ADD resources/.rpmmacros $HOME/.rpmmacros
RUN chmod +x /createrepo.sh /sign-rpm-packages.sh

WORKDIR /dist
ENTRYPOINT ["/createrepo.sh"]
