#!/bin/bash
VERSION=1.7.0-60
ACQUIA_VERSION=1
FOLDER=jdk${VERSION/-/_}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -f /tmp/jvm.tgz ]; then
  wget -O /tmp/jvm.tgz http://acquia_rpms.s3.amazonaws.com/all/jdk-7u60-linux-x64.gz
fi

# Move so that we can store java in the /usr/local/jdk directory
tar -xzvf /tmp/jvm.tgz -C /tmp/
mv /tmp/${FOLDER} /tmp/jvm

fpm -s dir -t deb -a amd64 -n oracle-jdk-7 \
  --after-install ${SCRIPT_DIR}/../files/oracle-java7-jdk/postinst \
  --before-remove ${SCRIPT_DIR}/../files/oracle-java7-jdk/prerm \
  -m "hosting-eng@acquia.com" \
  -v "${VERSION}-acquia${ACQUIA_VERSION}" "/tmp/jvm"=/usr/local/

if [ -d "/vagrant/" ]; then
  mv -f *.deb /vagrant/
fi
