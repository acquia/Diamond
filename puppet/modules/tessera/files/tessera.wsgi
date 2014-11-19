import os, sys
import site

tessera_base_dir='/opt/tessera/'
python_version="python{0}.{1}".format(sys.version_info.major, sys.version_info.minor)
python_site_packages_dir=os.path.join(tessera_base_dir, python_version, 'site-packages')

if os.path.isdir(python_site_packages_dir):
  site.addsitedir(python_site_packages_dir)

sys.path.append(os.path.join(tessera_base_dir))
os.environ['TESSERA_CONFIG'] = tessera_base_dir + 'etc/config.py'

from tessera import app

application = app
