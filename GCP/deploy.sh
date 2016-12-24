#! /bin/bash

TAG=$1
RED='\033[0;31m'
NC='\033[0m' # No Color

# make sure the specified tag is actually real
printf "${RED}+++++++++++++++++++++++++++ VERIFYING DEPLOY TAG ++++++++++++++++++++++++++++++++++++++++++++${NC}\n"
pushd .
cd ../synchro_app
if ! git ls-remote --tags | grep $TAG
then
        printf "${RED}Error -- Make sure the tag exists and has been pushed to remote!${NC}\n"
	exit
fi
popd

# Modify the startup script so that it points to the tag we are deploying
sed -i -e "s/\(git checkout \).*/\1$TAG/" instance_startup_script.sh

# Make an instance template w/ Startup Script that points to the tag to be deployed
printf "${RED}++++++++++++++++++++++++++++ CREATE INSTANCE TEMPLATE +++++++++++++++++++++++++++++++++++++++${NC}\n"
gcloud compute instance-templates create synchro-deploy-$TAG \
--image synchro-platform-image \
--metadata-from-file startup-script="instance_startup_script.sh"

# Make 2 new IGs from the IT we just made (Blue IG)
# Group A
printf "${RED}++++++++++++++++++++++++++++ CREATE INSTANCE GROUP A ++++++++++++++++++++++++++++++++++++++++${NC}\n"
gcloud compute --project "synchro-platform" instance-groups managed create "instance-group-$TAG-a" --zone "us-central1-f" --base-instance-name "instance-group-$TAG-a" --template "synchro-deploy-$TAG" --size "1"
gcloud compute --project "synchro-platform" instance-groups managed set-autoscaling "instance-group-$TAG-a" --zone "us-central1-f" --cool-down-period "60" --max-num-replicas "10" --min-num-replicas "1" --target-load-balancing-utilization "0.8"
gcloud beta compute instance-groups managed set-autohealing "instance-group-$TAG-a" --initial-delay="300" --http-health-check="instance-group-1-hc" --zone="us-central1-f"

# Group B
printf "${RED}+++++++++++++++++++++++++++ CREATE INSTANCE GROUP B +++++++++++++++++++++++++++++++++++++++++${NC}\n"
gcloud compute --project "synchro-platform" instance-groups managed create "instance-group-$TAG-b" --zone "us-east1-c" --base-instance-name "instance-group-$TAG-b" --template "synchro-deploy-$TAG" --size "1"
gcloud compute --project "synchro-platform" instance-groups managed set-autoscaling "instance-group-$TAG-b" --zone "us-east1-c" --cool-down-period "60" --max-num-replicas "10" --min-num-replicas "1" --target-load-balancing-utilization "0.8"
gcloud beta compute instance-groups managed set-autohealing "instance-group-$TAG-b" --initial-delay="300" --http-health-check="instance-group-1-hc" --zone="us-east1-c"

# Wait for instance groups to be ready
printf "${RED}+++++++++++++++++++++++++++ WAIT FOR INSTANCE GROUPS TO BE READY ++++++++++++++++++++++++++++${NC}\n"
sleep 30

# Add the new IGs as backends to the synchro-backend-service
# Group A
printf "${RED}+++++++++++++++++++++++++++ ADD GROUP A TO BACKEND SERVICE ++++++++++++++++++++++++++++++++++${NC}\n"
gcloud compute backend-services add-backend synchro-backend-service --instance-group="instance-group-$TAG-a" --balancing-mode="RATE" --max-rate-per-instance="80" --capacity-scaler="1.0" --instance-group-zone="us-central1-f"

printf "${RED}+++++++++++++++++++++++++++ ADD GROUP B TO BACKEND SERVICE ++++++++++++++++++++++++++++++++++${NC}\n"
gcloud compute backend-services add-backend synchro-backend-service --instance-group="instance-group-$TAG-b" --balancing-mode="RATE" --max-rate-per-instance="80" --capacity-scaler="1.0" --instance-group-zone="us-east1-c"

# Invalidate Cloud CDN cache
printf "${RED}+++++++++++++++++++++++++++ INVALIDATING LOAD BALANCER CACHE ++++++++++++++++++++++++++++++++++${NC}\n"
gcloud compute url-maps invalidate-cdn-cache synchro-load-balancer --path="/*"


# Remove the old (Green IG) from backend service
