#!/bin/bash
#
# Script to download and create the Oracle JDK deb pakage
#
set -x

VERSION=1.7.0-60
ACQUIA_VERSION=1
FOLDER=jdk${VERSION/-/_}
SCRIPT_NAME="$( dirname "${BASH_SOURCE[0]}" )"
BASEDIR="$( cd ${SCRIPT_NAME} ) && pwd )"

if [ ! -f /tmp/jvm.tgz ]; then
  wget -O /tmp/jvm.tgz http://acquia_rpms.s3.amazonaws.com/all/jdk-7u60-linux-x64.gz
fi

# Move so that we can store java in the /usr/local/jdk directory
tar -xzvf /tmp/jvm.tgz -C /tmp/
mv /tmp/${FOLDER} /tmp/jvm

# Setup pre and post scripts
INIT_SCRIPTS=${BASEDIR}/${SCRIPT_NAME}/scripts
test -d ${INIT_SCRIPTS} || mkdir -p ${INIT_SCRIPTS}

# Post Install script
cat << __EOF__ > ${INIT_SCRIPTS}/postinst
#!/bin/bash -e
JAVA_DIR=/usr/local/jvm

for FILE in ${JAVA_DIR}/bin/*
do
  JAVA_FILE=$(basename $FILE)
  update-alternatives --install "/usr/local/bin/${JAVA_FILE}" $JAVA_FILE $FILE 1
  update-alternatives --set $JAVA_FILE $FILE
done

__EOF__

# Pre-remove script
cat << __EOF__ > ${INIT_SCRIPTS}/prerm
#!/bin/bash -e
JAVA_DIR=/usr/local/jvm

if [ "$1" = "remove" ] || [ "$1" = "deconfigure" ]; then
  for FILE in $JAVA_DIR/bin/*
  do
    update-alternatives --remove $(basename $FILE) $FILE
  done
fi

__EOF__

# Create the deb
fpm -s dir -t deb -a amd64 -n oracle-jdk-7 \
  --after-install ${INIT_SCRIPTS}/postinst \
  --before-remove ${INIT_SCRIPTS}/prerm \
  -m "hosting-eng@acquia.com" \
  -v "${VERSION}-acquia${ACQUIA_VERSION}" "/tmp/jvm"=/usr/local/

# Clean up
rm -rf ${INIT_SCRIPTS}

# If in a VM copy then deb file over
if [ -d "/vagrant/" ]; then
  mkdir -p /vagrant/dist
  mv -f *.deb /vagrant/dist
fi
