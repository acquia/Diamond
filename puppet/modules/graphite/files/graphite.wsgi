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

