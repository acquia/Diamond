#!/bin/bash
OS=(trusty)

# Loop though the list of given OS types and download the matching puppetlabs deb package
for dist in ${OS[@]}
do
  curl -s -O https://apt.puppetlabs.com/puppetlabs-release-${dist}.deb
done

# If in a VM copy then deb file over
if [ -d "/vagrant/" ]; then
  mv -f *.deb /vagrant/
fi