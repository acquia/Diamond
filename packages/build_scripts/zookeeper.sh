#!/usr/bin/env bash
#
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
#
#
# Package Apache Zookeeper and Netflix Exhibitor
#
set -ex

NAME="zookeeper"
VERSION="3.4.6"
EXHIBITOR_VERSION="1.5.5"
EXHIBITOR_BRANCH="v1.5.5-6-g3b0132b"

OS=$(lsb_release -cs)
ARCH=$(uname -m)

BASEDIR=/tmp/${NAME}
rm -rf ${BASEDIR}
mkdir -p ${BASEDIR}

apt-get update -y
apt-get install -y build-essential software-properties-common python-software-properties

echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
add-apt-repository -y ppa:webupd8team/java
apt-get update -y
apt-get install -y oracle-java7-installer ant maven

# Build current stable Zookeeper version from Apache dist
curl -o ${BASEDIR}/zookeeper-${VERSION}.tar.gz http://www.apache.org/dist/zookeeper/zookeeper-${VERSION}/zookeeper-${VERSION}.tar.gz
cd ${BASEDIR}
tar -xvzf ${BASEDIR}/zookeeper-${VERSION}.tar.gz
mv ${BASEDIR}/zookeeper-${VERSION} ${BASEDIR}/zookeeper

# Build the binary and setup the install package paths
cd ${BASEDIR}/zookeeper

# Remove dependency on java6
sed -i '/Depends/c Depends: ' ./src/packages/deb/zookeeper.control/control

# Remove explicit references to java6, replacing with system java.
JRE_PATH=$(readlink -e $(which java) | sed -e 's/\/bin\/java$//')
sed -i -e 's,JAVA_HOME=/usr/lib/jvm/java-6-sun/jre$,'"JAVA_HOME=${JRE_PATH}"',g' ./src/packages/update-zookeeper-env.sh

BUILDDIR=${BASEDIR}/build
mkdir -p ${BUILDDIR}/opt
cp -a ${BASEDIR}/zookeeper ${BUILDDIR}/opt/zookeeper
mkdir -p ${BUILDDIR}/opt/zookeeper/transactions ${BUILDDIR}/opt/zookeeper/snapshots
cd ${BUILDDIR}
fpm --force -t deb -s dir \
  -a all \
  -a ${ARCH} \
  --vendor "Acquia, Inc." \
  --provides "${NAME}" \
  -n "${NAME}" \
  -v ${VERSION} \
  -m "hosting-eng@acquia.com" \
  --description "Acquia zookeeper ${VERSION} built on $(date +"%Y%m%d%H%M%S")" \
  .

mkdir -p ${BASEDIR}/zookeeper/build/
mv ${BUILDDIR}/${NAME}*.deb ${BASEDIR}/zookeeper/build/
cd ${BASEDIR}
rm -rf ${BUILDDIR}

# Build the current Exhibitor version
cd ${BASEDIR}
git clone https://github.com/Netflix/exhibitor.git
cd ${BASEDIR}/exhibitor
git checkout ${EXHIBITOR_BRANCH}
mvn package -f exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml
mkdir -p ${BASEDIR}/exhibitor/dist/opt/exhibitor/
cp -a ${BASEDIR}/exhibitor/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/target/exhibitor-*.jar ${BASEDIR}/exhibitor/dist/opt/exhibitor/exhibitor.jar

cd ${BASEDIR}/exhibitor/dist
fpm --force -t deb -s dir \
  -a all \
  -a ${ARCH} \
  --vendor "Acquia, Inc." \
  --provides "${NAME}-exhibitor" \
  -n "${NAME}-exhibitor" \
  -v ${EXHIBITOR_VERSION} \
  -m "hosting-eng@acquia.com" \
  --description "Acquia zookeeper-exhibitor ${EXHIBITOR_VERSION} built on $(date +"%Y%m%d%H%M%S")" \
  .

# If we're in a VM, let's copy the deb file over
if [ -d "/dist/" ]; then
  mv -f ${BASEDIR}/zookeeper/build/${NAME}*.deb ${BASEDIR}/exhibitor/dist/${NAME}*.deb /dist/
fi

rm -rf ${BASEDIR}