#!/bin/bash

set -e

opkg update

opkg install git git-http screen python3 python3-pip python3-crypto mosquitto haveged
pip3 install --upgrade setuptools
pip3 install paho-mqtt pyaes tornado

