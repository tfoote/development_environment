#!/bin/bash

set -o errexit

apt-get update
apt-get install -y ruby
gem install puppet --no-rdoc --no-ri
puppet module install garethr-docker
puppet module install puppetlabs-ntp
puppet module install saz-timezone
puppet module install tracywebtech-pip
puppet module install example42-iptables
