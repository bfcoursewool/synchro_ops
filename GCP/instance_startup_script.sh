#! /bin/bash

## TODO -- Surely there is a way to do this with Chef or Ansible which would be better. 
## Once I have some time for the learning curve, we should use that method. 

# Grab the Synchro Platform from the app repo
cd /var/www/html
git clone https://github.com/bfcoursewool/synchro_ops.git
cd synchro_ops
git submodule init
git submodule update
cd synchro_app
git checkout v2-8b

# Move apache configs from ops repo & restart apache
mv /var/www/html/synchro_ops/GCP/000-default.conf /etc/apache2/sites-enabled

# Install the platform
cd /var/www/html/synchro_ops/synchro_app 
python setup.py install
pip install -r requirements.txt

# Restart Apache
/etc/init.d/apache2 restart
