#!/usr/bin/env bash
#
# Packages tablesnap for s3 backup of Cassandra sstables
#

NAME="tablesnap"
VERSION="0.6.2"
DEB_BUILD_VERSION="1"

ARCH=$(uname -m)
OS=$(lsb_release -cs)

if [ "$ARCH" = "i686" ]; then
  ARCH="i386"
fi

BASEDIR=/opt/tablesnap

# Pip install a specified Github repo
#
# @param $1 owner
# @param $2 repo name
# @param $3 tag/branch name [default: 'master']
# @param $4 private or public repo [default: 'public']
function gh-pip() {
  if [ "${4:-public}" == "private" ]; then
    pip install git+ssh://git@github.com/${1}/${2}.git@${3:-"master"}
  else
    pip install git+https://github.com/${1}/${2}.git@${3:-"master"}
  fi
}

# Install the build deps needed to create the packages
apt-get install -y git-core python-virtualenv python-pip python-dev

# Setup the virtual env
mkdir -p $BASEDIR
virtualenv $BASEDIR
source ${BASEDIR}/bin/activate

# Disable host key checking for github since pip doesnt allow the flags for
# -oStrictHostKeyChecking=no
cp -a /home/vagrant/.ssh /root/.ssh
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
chmod -R 600 /root/.ssh

# Install any git packaged repos
gh-pip 'acquia' 'tablesnap'

# Write out the config and init scripts
mkdir -p ${BASEDIR}/etc/tablesnap
( cat <<- EOF > ${BASEDIR}/etc/tablesnap/tablesnap.init
#! /bin/sh
#
### BEGIN INIT INFO
# Provides:          tablesnap
# Required-Start:    \$syslog
# Required-Stop:     \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: tablesnap
# Description:       Starts Tablesnap,for saving Cassandra data to S3
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/opt/tablesnap/bin
DAEMON=/opt/tablesnap/bin/tablesnap
NAME=tablesnap
DESC=tablesnap

test -x \$DAEMON || exit 0

LOGDIR=/var/log/tablesnap
PIDFILE=/var/run/\$NAME.pid

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

# Include defaults if available
if [ -f /etc/default/tablesnap ] ; then
    . /etc/default/tablesnap
fi

# Enable the python venv
. /opt/tablesnap/bin/activate

if [ "\$RUN" != "yes" ]; then
    echo "Set RUN=yes in /etc/default/tablesnap to start"
    exit 0
fi

set -e

daemon_start() {
    log_daemon_msg "Starting \$DESC daemon" "\$NAME"
    start-stop-daemon --start --quiet --oknodo --make-pidfile --background \\
        --name "\$NAME" --pidfile \$PIDFILE --exec \$DAEMON -- \$DAEMON_OPTS
    status=\$?
    log_end_msg \$status
}

daemon_stop() {
    log_daemon_msg "Stopping \$DESC daemon" "\$NAME"
    start-stop-daemon --stop --quiet --oknodo --pidfile \$PIDFILE \\
        --name "\$NAME"
    log_end_msg \$?
    rm -f \$PIDFILE
}

case "\$1" in
  start)
    daemon_start || exit 1
    ;;
  stop)
    daemon_stop || exit 1
    ;;
  restart)
    daemon_stop
    daemon_start || exit 1
    ;;
  status)
    status_of_proc "\$DAEMON" "\$NAME" && exit 0 || exit \$?
    ;;
  *)
    N=/etc/init.d/\$NAME
    echo "Usage: \$N {start|stop|restart|status}" >&2
    exit 1
    ;;
esac

exit 0

EOF
)

( cat <<- EOF > ${BASEDIR}/etc/tablesnap/tablesnap.default
# Defualt config file used by tablesnap init script, copy to /etc/default/tablesnap
RUN=no
DAEMON_OPTS="-k <AWS_ACCESS_KEY> -s <AWS_SECRET_KEY> <AWS_S3_BUCKET> <PATH_TO_BACKUP>"

# Log to syslog
export TABLESNAP_SYSLOG=True

EOF
)

# Disable the virtual env
deactivate

# Create the deb
fpm -t deb -s dir \
  -a ${ARCH} \
  --vendor "Acquia, Inc." \
  --provides "tablesnap" \
  --depends "cassandra" \
  --depends "python" \
  --depends "python-virtualenv" \
  --depends "libffi-dev" \
  --deb-init "${BASEDIR}/etc/tablesnap/tablesnap.init" \
  -n ${NAME} \
  -v ${VERSION}-${DEB_BUILD_VERSION}~${OS} \
  -m "hosting-eng@acquia.com" \
  --description "Acquia ${NAME} ${VERSION} built on $(date +"%Y%m%d%H%M%S")" \
  ${BASEDIR}

# If we're in a VM, let's copy the deb file over
if [ -d "/vagrant/" ]; then
  mkdir -p /vagrant/dist
  mv -f *.deb /vagrant/dist/
fi
