#!/bin/bash

sudo apt-get update
sudo apt-get -y install vim curl
sudo apt-get -y install nodejs npm
# Cause apt calls it nodejs... 
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g grunt-cli
sudo apt-get -y install python-pip
sudo pip install virtualenv
sudo gem install compass

su -c "/vagrant/user-config.sh" vagrant
