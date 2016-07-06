#!/bin/bash

set -o errexit

apt-get update
apt-get install -y ruby ruby-dev librarian-puppet

# config for librarian for more efficient syncronization
librarian-puppet config rsync true --global
