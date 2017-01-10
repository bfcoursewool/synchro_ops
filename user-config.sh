#!/bin/bash

cd /home/vagrant

if [ ! -d /home/vagrant/synchro_venv ]; then
  virtualenv synchro_venv
fi

# Put a nice vimrc in place
cp /vagrant/configs/vimrc /home/vagrant/.vimrc

# Put a .bashrc in place
cp /vagrant/configs/bashrc /home/vagrant/.bashrc

source /home/vagrant/synchro_venv/bin/activate
# install pip packages
cd /vagrant/synchro_app && pip install -r requirements.txt

# install npm packages
cd /vagrant && npm install
cd /vagrant/synchro_app/synchro/resources/bootstrap && npm install

if [ ! -L ~/synchro_app ]; then
  ln -s /vagrant/synchro_app ~/synchro_app
fi 
