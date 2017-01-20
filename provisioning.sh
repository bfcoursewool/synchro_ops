#!/bin/bash

sudo apt-get update
sudo apt-get -y install vim curl
sudo apt-get -y install nodejs npm
sudo apt-get -y install libmysqlclient-dev
sudo apt-get -y install libpython-dev

# Install MySQL
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password synchroroot'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password synchroroot'
sudo apt-get -y install mysql-client-5.5 mysql-server-5.5
sudo mysql_install_db --force
echo "create database synchro_db" | sudo mysql -u root -psynchroroot


# Cause apt calls it nodejs... 
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g grunt-cli
sudo apt-get -y install python-pip
sudo pip install virtualenv
sudo apt-get -y install ruby-dev
sudo gem install compass

su -c "/vagrant/user-config.sh" vagrant
