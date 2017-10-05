#!/bin/bash

# Supposed to run inside a Docker container
adduser --disabled-password --gecos "" test
(cd /manokwari && ./autogen.sh && make && make install)
sudo -H -u test XDG_SESSION_TYPE=x11 /usr/bin/blankon-session
