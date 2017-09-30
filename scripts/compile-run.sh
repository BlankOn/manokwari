#!/bin/bash

# Supposed to run inside a Docker container
adduser --disabled-password --gecos "" test
(cd /manokwari && make && make install)
sudo -H -u test /usr/bin/manokwari
