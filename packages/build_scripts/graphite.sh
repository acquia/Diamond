#!/bin/bash
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
# Packages Graphite for distribution
#
#  This package will setup a venv for graphite to run out of /opt/graphite and
#  will install all dependencies into /opt/graphite/lib/pythonX.X/site-packages
#
set -x

NAME="graphite"
VERSION="0.1.0"
DEB_BUILD_VERSION="1"

OS=$(lsb_release -cs)
ARCH=$(uname -m)

if [ "$ARCH" = "i686" ]; then
  ARCH="i386"
fi

BASEDIR=/opt/graphite

# Graphite python dependencies to install into the virtual env
dependencies=$( cat <<EOF
cairocffi
pycassa
Django
Twisted<12.0
tagging
django-tagging
pytz
pyparsing
simplejson
whisper
EOF
)

# Pip install a specified Github repo
#
# @param $1 owner
# @param $2 repo name
# @param $3 tag/branch name [default: 'master']
function gh-pip() {
  pip install git+ssh://git@github.com/${1}/${2}.git@${3:-"master"}
}

# Install the build deps needed to create the packages
apt-get install -y git python-virtualenv python-pip python-cairo python-dev libffi-dev

# Setup the virtual env
mkdir -p $BASEDIR
virtualenv $BASEDIR
source ${BASEDIR}/bin/activate

# Install package dependencies
for dep in $dependencies
do
  pip install $dep
done

# Disable host key checking for github since pip doesnt allow the flags for
# -oStrictHostKeyChecking=no
cp -a /home/vagrant/.ssh /root/.ssh
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
chmod -R 600 /root/.ssh

# Install any git packaged repos
gh-pip 'acquia' 'graphite-web' 'db-plugin'
gh-pip 'acquia' 'ceres'
gh-pip 'acquia' 'carbon' 'db-plugin'
gh-pip 'acquia' 'carbon-cassandra-plugin'
gh-pip 'acquia' 'graphite-cassandra-plugin'

# Write graphite.wsgi to graphite-web conf so it can run out of the virtual env
( cat <<- EOF > $BASEDIR/conf/graphite.wsgi
import os, sys
import site

graphite_base_dir='/opt/graphite/'
python_version="python{0}.{1}".format(sys.version_info.major, sys.version_info.minor)
python_site_packages_dir=os.path.join(graphite_base_dir, python_version, 'site-packages')

if os.path.isdir(python_site_packages_dir):
  site.addsitedir(python_site_packages_dir)

sys.path.append(os.path.join(graphite_base_dir, 'webapp'))
os.environ['DJANGO_SETTINGS_MODULE'] = 'graphite.settings'

import django.core.handlers.wsgi

application = django.core.handlers.wsgi.WSGIHandler()

# Initializing the search index can be very expensive, please include
# the WSGIImportScript directive pointing to this script in your vhost
# config to ensure the index is preloaded before any requests are handed
# to the process.
from graphite.logger import log
log.info("graphite.wsgi - pid %d - reloading search index" % os.getpid())
import graphite.metrics.search

EOF
)

# Write graphite-web.conf for mod_wsgi so it can run out of the virtual env
( cat <<- EOF > $BASEDIR/conf/graphite-web.conf
WSGISocketPrefix /var/run/apache2/wsgi

<VirtualHost *:80>
  ServerName graphite
  ServerAlias *
  DocumentRoot "/opt/graphite/webapp"
  ErrorLog /opt/graphite/storage/log/webapp/error.log
  CustomLog /opt/graphite/storage/log/webapp/access.log common

  WSGIDaemonProcess graphite processes=5 threads=5 display-name='%{GROUP}' inactivity-timeout=120 python-path=/opt/graphite/lib/python2.7/site-packages
  WSGIProcessGroup graphite
  WSGIApplicationGroup %{GLOBAL}
  WSGIImportScript /opt/graphite/conf/graphite.wsgi process-group=graphite application-group=%{GLOBAL}
  WSGIScriptAlias / /opt/graphite/conf/graphite.wsgi

  <Directory />
      Options FollowSymLinks
      AllowOverride All
  </Directory>

  Alias /content/ /opt/graphite/webapp/content/
  <Location "/content/">
    SetHandler None
  </Location>

  Alias /media/ "/opt/graphite/lib/python2.7/site-packages/django/contrib/admin/static/admin/"
  <Location "/media/">
    SetHandler None
  </Location>

  <Directory /opt/graphite/conf/>
    Order deny,allow
    Allow from all
  </Directory>

</VirtualHost>
EOF
)

# Disable the virtual env
deactivate

# Create the deb
fpm -t deb -s dir \
  --deb-user www-data --deb-group www-data \
  -a ${ARCH} \
  --vendor "Acquia, Inc." \
  --provides "graphite" \
  --provides "carbon" \
  --depends "apache2" \
  --depends "libapache2-mod-wsgi" \
  --depends "python" \
  --depends "python-virtualenv" \
  --depends "libffi-dev" \
  --depends "libcairo2" \
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
