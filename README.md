see https://forwardhq.com/login for host-forwarding account. 

<b>To install the Synchro App dev environment: <br><b>

git clone git@github.com:bfcoursewool/synchro_ops.git <br />
cd synchro_ops <br />
git submodule init <br />
git submodule update <br />

<b>install vagrant then: <br /></b>

vagrant up <br />
vagrant ssh <br />

<b> within the vagrant box... </b>
cd synchro_app
python synchro_app


Now you can visit localhost:1337 in a browser on your local machine and you should see the project. 

