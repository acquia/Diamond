#!/bin/bash

BASEDIR=/tmp

rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
yum clean expire-cache
yum install -y --downloadonly --downloaddir=${BASEDIR}/puppet/ puppet

if [ -d "/dist/" ]; then
  mv -f ${BASEDIR}/puppet/*.rpm /dist/
fi
