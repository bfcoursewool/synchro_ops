see https://forwardhq.com/login for host-forwarding account. 

<b>To install the Synchro App dev environment: <br></b>

git clone git@github.com:bfcoursewool/synchro_ops.git <br />
cd synchro_ops <br />
git submodule init <br />
git submodule update <br />
cd synchro_app <br />
git checkout develop <br /> 

<b>install vagrant, then, from the synchro_ops directory: <br /></b>

vagrant up <br />
vagrant ssh <br />

<b> within the vagrant box... </b> <br />
cd synchro_app <br />
python synchro_app.py


Now you can visit localhost:1337 in a browser on your local machine and you should see the project. 

