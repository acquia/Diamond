#!/bin/bash
#
# Run puppet apply without updating nemesis-puppet package or sending output to /var/log/puppet.log
#

# Check to see if nemesis-puppet package needs to be updated
yum clean all expire-cache

# Export all necessary environment variables
export RUBYLIB=/etc/puppet/lib:$RUBYLIB
export AMAZON_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')

# Run puppet
cd /etc/puppet && puppet apply manifests/nodes.pp --modulepath=/etc/puppet/modules:/etc/puppet/modules/third_party --no-stringify_facts
