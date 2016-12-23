#! /bin/bash

TAG=$1

# make sure the specified tag is actually real
echo "+++++++++++++++++++++++++++ VERIFYING DEPLOY TAG ++++++++++++++++++++++++++++++++++++++++++"
pushd .
cd ../synchro_app
if ! git ls-remote --tags | grep $TAG
then
        echo "Error -- Make sure the tag exists and has been pushed to remote!"
	exit
fi
popd

# Modify the startup script so that it points to the tag we are deploying
sed -i -e "s/\(git checkout \).*/\1$TAG/" instance_startup_script.sh

# Make an instance template w/ Startup Script that points to the tag to be deployed
echo "++++++++++++++++++++++++++++ CREATE INSTANCE TEMPLATE +++++++++++++++++++++++++++++++++++++++"
gcloud compute instance-templates create synchro-deploy-$TAG \
--image synchro-platform-image \
--metadata-from-file startup-script="instance_startup_script.sh"

# Make 2 new IGs from the IT we just made (Blue IG)
# Group A
echo "++++++++++++++++++++++++++++ CREATE INSTANCE GROUP A ++++++++++++++++++++++++++++++++++++++++"
gcloud compute --project "synchro-platform" instance-groups managed create "instance-group-$TAG-a" --zone "us-central1-f" --base-instance-name "instance-group-$TAG-a" --template "synchro-deploy-$TAG" --size "1"
gcloud compute --project "synchro-platform" instance-groups managed set-autoscaling "instance-group-$TAG-a" --zone "us-central1-f" --cool-down-period "60" --max-num-replicas "10" --min-num-replicas "1" --target-load-balancing-utilization "0.8"
gcloud beta compute instance-groups managed set-autohealing "instance-group-$TAG-a" --initial-delay="300" --http-health-check="instance-group-1-hc" --zone="us-central1-f"

# Group B
echo "+++++++++++++++++++++++++++ CREATE INSTANCE GROUP B +++++++++++++++++++++++++++++++++++++++++"
gcloud compute --project "synchro-platform" instance-groups managed create "instance-group-$TAG-b" --zone "us-east1-c" --base-instance-name "instance-group-$TAG-b" --template "synchro-deploy-$TAG" --size "1"
gcloud compute --project "synchro-platform" instance-groups managed set-autoscaling "instance-group-$TAG-b" --zone "us-east1-c" --cool-down-period "60" --max-num-replicas "10" --min-num-replicas "1" --target-load-balancing-utilization "0.8"
gcloud beta compute instance-groups managed set-autohealing "instance-group-$TAG-b" --initial-delay="300" --http-health-check="instance-group-1-hc" --zone="us-east1-c"

# Wait for instance groups to be ready
echo "+++++++++++++++++++++++++++ WAIT FOR INSTANCE GROUPS TO BE READY ++++++++++++++++++++++++++++"
sleep 30

# Add the new IGs as backends to the synchro-backend-service
# Group A
echo "+++++++++++++++++++++++++++ ADD GROUP A TO BACKEND SERVICE ++++++++++++++++++++++++++++++++++"
gcloud compute backend-services add-backend synchro-backend-service --instance-group="instance-group-$TAG-a" --balancing-mode="RATE" --max-rate-per-instance="80" --capacity-scaler="1.0" --instance-group-zone="us-central1-f"

echo "+++++++++++++++++++++++++++ ADD GROUP B TO BACKEND SERVICE ++++++++++++++++++++++++++++++++++"
gcloud compute backend-services add-backend synchro-backend-service --instance-group="instance-group-$TAG-b" --balancing-mode="RATE" --max-rate-per-instance="80" --capacity-scaler="1.0" --instance-group-zone="us-east1-c"

# Invalidate Cloud CDN cache
gcloud compute url-maps invalidate-cdn-cache synchro-load-balancer --path="/*"


# Remove the old (Green IG) from backend service
