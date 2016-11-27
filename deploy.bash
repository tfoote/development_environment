#!/bin/bash

set -o errexit

sudo cp hiera.yaml /etc/puppet
sudo mkdir -p /etc/puppet/hieradata
sudo cp common.yaml /etc/puppet/hieradata

librarian-puppet install --verbose
sudo puppet apply -v site.pp --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:`pwd`:`pwd`/modules #-l /var/log/puppet.log
