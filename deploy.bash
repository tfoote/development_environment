#!/bin/bash

set -o errexit

cp hiera.yaml /etc/puppet
mkdir -p /etc/puppet/hieradata
cp common.yaml /etc/puppet/hieradata

puppet module --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:`pwd` list
puppet apply -v site.pp --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:`pwd` #-l /var/log/puppet.log
