#!/bin/bash

VERSION=1.9.0-1.el7.centos

BASEDIR=/tmp

cat << EOF > /etc/yum.repos.d/docker.repo
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum clean expire-cache
yum install -y --downloadonly --downloaddir=${BASEDIR}/docker/ docker-engine-${VERSION}

if [ -d "/dist/" ]; then
  mv -f ${BASEDIR}/docker/*.rpm /dist/
fi
