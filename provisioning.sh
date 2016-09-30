#!/bin/bash

sudo apt-get update
sudo apt-get -y install vim curl
sudo apt-get -y install nodejs npm
#sudo npm install -g grunt-cli
sudo apt-get -y install python-pip
sudo pip install virtualenv

su -c "/vagrant/user-config.sh" vagrant
