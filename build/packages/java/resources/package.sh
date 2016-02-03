#!/bin/bash

: ${JAVA_VERSION:=8u72-b15}
: ${PACKAGE_DIST_DIR:=/dist}

JAVA_VERSION_MAJOR=$(echo ${JAVA_VERSION} | cut -d'-' -f1)
BASEDIR=/tmp

cd ${BASEDIR}
/bin/curl -sSL -OJ -H 'Cookie: oraclelicense=accept-securebackup-cookie' http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}/jdk-${JAVA_VERSION_MAJOR}-linux-x64.rpm

if [ -d "${PACKAGE_DIST_DIR}" ]; then
  mv -f ${BASEDIR}/*.rpm ${PACKAGE_DIST_DIR}/
fi
