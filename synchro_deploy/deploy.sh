#!/bin/bash
## Theoretically the next evolution of this is to use a deployment manager like Chef/Puppet/Ansible to do the 
## actual provisioning and subsequent releases... but for now it's good enough to just script out some k8s & 
## docker commands.

RED='\033[0;31m'
NC='\033[0m' # No Color

TAG=$1
FLAGS=$2
REGISTRY_HOST='gcr.io'
PROJECT='synchro-platform'
APP_NAME='synchro'
APP_DIR='synchro_app'
BUCKET_NAME='synchro-assets'
DEPLOYMENT_FILE='synchro_deployment.yml'

SECRETSMAP_FILE='synchro_secretsmap.yml'
CONFIGMAP_FILE='synchro_configmap.yml'

K8S_CONTEXT='gke_synchro-platform_us-west1-b_synchro-landing-pages'

printf "${RED}++++++++++++++++++++++ DOCKER LOGIN / K8S CONTEXT SWITCHING +++++++++++++++++++++++++++++++++++++++++${NC}\n"

gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io
kubectl config use-context $K8S_CONTEXT

## make sure the specified tag is actually real
printf "${RED}++++++++++++++++++++++++++++++ VERIFYING DEPLOY TAG +++++++++++++++++++++++++++++++++++++++++++++++++${NC}\n"
pushd .
cd ../${APP_DIR}
if ! git ls-remote --tags | grep $TAG
then
  printf "${RED}Error -- Make sure the tag exists and has been pushed to remote!${NC}\n"
  exit
fi
git checkout $TAG 
popd


## Take care of the front-end static assets (js and css)
pushd .
cd ..

## TODO -- Run Unit Tests!

printf "${RED}+++++++++++++++++++++++++++ TRANSPILING FRONT-END ASSETS ++++++++++++++++++++++++++++++++++++++++++++${NC}\n"
yarn build --define process.env.RELEASE_TAG="\"$TAG\""
cp ${APP_DIR}/${APP_NAME}/static/${APP_NAME}.bundle.js ${APP_DIR}/${APP_NAME}/static/production/
cp ${APP_DIR}/${APP_NAME}/static/${APP_NAME}.css ${APP_DIR}/${APP_NAME}/static/production/
cp ${APP_DIR}/${APP_NAME}/static/${APP_NAME}.bundle.js.map ${APP_DIR}/${APP_NAME}/static/production/
cp ${APP_DIR}/${APP_NAME}/static/${APP_NAME}.css.map ${APP_DIR}/${APP_NAME}/static/production/

printf "${RED}+++++++++++++++++++++++++++ UPLOADING ASSETS TO CLOUD STORAGE ++++++++++++++++++++++++++++++++++++++++++${NC}\n"
gzip < ${APP_DIR}/${APP_NAME}/static/${APP_NAME}.bundle.js > ${APP_DIR}/${APP_NAME}/static/production/${APP_NAME}.bundle.js 
gzip < ${APP_DIR}/${APP_NAME}/static/${APP_NAME}.css > ${APP_DIR}/${APP_NAME}/static/production/${APP_NAME}.css

gsutil -h "Content-Type: application/x-javascript" -h "Content-Encoding: gzip" cp ${APP_DIR}/${APP_NAME}/static/production/${APP_NAME}.bundle.js gs://${BUCKET_NAME}/static
gsutil -h "Content-Type: text/css" -h "Content-Encoding: gzip" cp ${APP_DIR}/${APP_NAME}/static/production/${APP_NAME}.css gs://${BUCKET_NAME}/static

gsutil acl ch -u AllUsers:R gs://${BUCKET_NAME}/static/${APP_NAME}.bundle.js
gsutil acl ch -u AllUsers:R gs://${BUCKET_NAME}/static/${APP_NAME}.css 

printf "${RED}+++++++++++++++++++++++++++++ BUILDING DOCKER CONTAINER +++++++++++++++++++++++++++++++++++++++++++++${NC}\n"
docker build -t ${REGISTRY_HOST}/${PROJECT}:${TAG} $APP_DIR/


printf "${RED}+++++++++++++++++++++++++++++ PUSHING CONTAINER TO REGISTRY +++++++++++++++++++++++++++++++++++++++++${NC}\n"
docker push ${REGISTRY_HOST}/${PROJECT}:${TAG}

popd

printf "${RED}+++++++++++++++++++++++++++++ UPDATING K8S DEPLOYMENT +++++++++++++++++++++++++++++++++++++++++++++++${NC}\n"
kubectl apply -f $SECRETSMAP_FILE
kubectl apply -f $CONFIGMAP_FILE
sed -i -e "s/\(image: \).*/\1${REGISTRY_HOST}\/${PROJECT}:${TAG}/" $DEPLOYMENT_FILE
kubectl apply -f $DEPLOYMENT_FILE

if [ "$CELERY_FLAG" = "--with-celery" ]
then
  sed -i -e "s/\(image: \).*/\1${REGISTRY_HOST}\/${PROJECT}:${TAG}/" $WORKER_DEPLOYMENT_FILE
  kubectl apply -f $RABBITMQ_DEPLOYMENT
  kubectl apply -f $RABBITMQ_SERVICE
  kubectl apply -f $WORKER_DEPLOYMENT_FILE
fi

printf "${RED}++++++++++++++++++++++++++++++++++++++ DONE!! +++++++++++++++++++++++++++++++++++++++++++++++++++++++${NC}\n"