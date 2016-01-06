#!/bin/bash

set -e

: ${ZOOKEEPER_VERSION:=3.4.7}
: ${EXHIBITOR_VERSION:=1.5.6}
: ${EXHIBITOR_BRANCH:=v1.5.6}
: ${PACKAGE_DIST_DIR:=/dist}

NAME="zookeeper"
ARCH=$(uname -m)

BASEDIR=/tmp

# Download and build the current stable Zookeeper version from Apache dist
mkdir -p ${BASEDIR}/zookeeper
curl -sSL http://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz | tar -xz --strip 1 -C ${BASEDIR}/zookeeper
cd ${BASEDIR}/zookeeper

BUILDDIR=${BASEDIR}/build
mkdir -p ${BUILDDIR}/opt
cp -a ${BASEDIR}/zookeeper ${BUILDDIR}/opt/zookeeper
mkdir -p ${BUILDDIR}/opt/zookeeper/transactions ${BUILDDIR}/opt/zookeeper/snapshots

# Package Zookeeper
cd ${BUILDDIR}
fpm --force -t rpm -s dir \
  -a all \
  -a ${ARCH} \
  --vendor "Acquia, Inc." \
  --provides "${NAME}" \
  -n "${NAME}" \
  -v ${ZOOKEEPER_VERSION} \
  -m "engineering@acquia.com" \
  --description "Acquia zookeeper ${ZOOKEEPER_VERSION} built on $(date +"%Y%m%d%H%M%S")" \
  .

mkdir -p ${BASEDIR}/zookeeper/build/
mv ${BUILDDIR}/${NAME}*.rpm ${BASEDIR}/zookeeper/build/
cd ${BASEDIR}
rm -rf ${BUILDDIR}

  # Build the current Exhibitor
mkdir -p ${BASEDIR}/exhibitor
curl -sSL https://github.com/Netflix/exhibitor/archive/${EXHIBITOR_BRANCH}.tar.gz | tar -xz --strip 1 -C ${BASEDIR}/exhibitor
cd ${BASEDIR}/exhibitor
mvn package -f exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml
mkdir -p ${BASEDIR}/exhibitor/dist/opt/exhibitor/
cp -a ${BASEDIR}/exhibitor/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/target/exhibitor-*.jar ${BASEDIR}/exhibitor/dist/opt/exhibitor/exhibitor.jar

# Package Exhibitor
cd ${BASEDIR}/exhibitor/dist
fpm --force -t rpm -s dir \
  -a all \
  -a ${ARCH} \
  --vendor "Acquia, Inc." \
  --provides "${NAME}-exhibitor" \
  -n "${NAME}-exhibitor" \
  -v ${EXHIBITOR_VERSION} \
  -m "engineering@acquia.com" \
  --description "Acquia zookeeper-exhibitor ${EXHIBITOR_VERSION} built on $(date +"%Y%m%d%H%M%S")" \
  .

if [ -d "${PACKAGE_DIST_DIR}" ]; then
  mv -f ${BASEDIR}/zookeeper/build/${NAME}*.rpm ${BASEDIR}/exhibitor/dist/${NAME}*.rpm ${PACKAGE_DIST_DIR}/
fi