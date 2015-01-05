#!/bin/bash

/opt/graphite/bin/acquia_maintenance.py --configdir=/opt/graphite/conf/carbon-daemons/writer/ \
  acquia_rollup --keyspace=graphite --servers=127.0.0.1
