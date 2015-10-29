#!/bin/bash

BASEDIR=/tmp

cd ${BASEDIR}
git clone https://github.com/python-diamond/Diamond.git diamond
cd ${BASEDIR}/diamond
make rpm

if [ -d "/dist/" ]; then
  mv -f dist/diamond-*.noarch.rpm /dist/
fi
