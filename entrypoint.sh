#!/bin/sh

# Put GCP service account key from base64 to json on a file if specified.
if [ -n "$GCLOUD_AUTH" ]
 then
  echo "$GCLOUD_AUTH" > "$HOME"/gcloud-service-key.json
# Put Docker Hub password to a text file if specified.
elif [ -n "$DOCKER_PASSWORD"$ ]
  then
   echo "$DOCKER_PASSWORD" > "$HOME"/docker-login_password.text
else
  echo "Not auth credentials specified"
fi

# If GCLOUD_AUTH is provided, then we setup registry url with project id
if [ -n "$GCLOUD_AUTH" ]
 then
  DOCKER_REGISTRY_URL="$REGISTRY_URL/$GCLOUD_PROJECT_ID"
else
  DOCKER_REGISTRY_URL="$REGISTRY_URL"
fi

DOCKER_IMAGE_NAME="$1"
DOCKER_REPO="$2"
DOCKER_IMAGE_TAG="$3"
DOCKER_DIR="$4"
DOCKER_TARGET="$5"

BUILD_ARG_1="${6:-BUILD_ARG_1}"
BUILD_ARG_2="${7:-BUILD_ARG_2}"
BUILD_ARG_3="${8:-BUILD_ARG_3}"
BUILD_ARG_4="${9:-BUILD_ARG_4}"
BUILD_ARG_5="${10:-BUILD_ARG_5}"
BUILD_ARG_6="${11:-BUILD_ARG_6}"
BUILD_ARG_7="${12:-BUILD_ARG_7}"
BUILD_ARG_8="${13:-BUILD_ARG_8}"
BUILD_ARG_9="${14:-BUILD_ARG_9}"

USERNAME=${GITHUB_REPOSITORY%%/*}
REPOSITORY=${GITHUB_REPOSITORY#*/}

REGISTRY=${DOCKER_REGISTRY_URL} ## use default Docker Hub as registry unless specified
NAMESPACE=${DOCKER_NAMESPACE:-$USERNAME} ## use github username as docker namespace unless specified
IMAGE_NAME=${DOCKER_IMAGE_NAME:-$REPOSITORY} ## use github repository name as docker image name unless specified
IMAGE_TAG=${DOCKER_IMAGE_TAG:-$GIT_TAG} ## use git ref value as docker image tag unless specified

echo "$GCLOUD_AUTH" > "$HOME"/gcloud-service-key.json
docker login -u _json_key --password-stdin australia-southeast1-docker.pkg.dev/headstart-270406/headstart/headstart < "$HOME"/gcloud-service-key.json
# Login Docker with GCP Service Account key or Docker username and password
if [ -n "$DOCKER_PASSWORD" ]
 then
  sh -c "cat "$HOME"/docker-login_password.text | docker login --username $DOCKER_USERNAME --password-stdin"
else 
  echo "Not docker authorization creteria provided. Skipping login"
fi


# Build Docker Image Locally with provided Image Name
sh -c "docker build $DOCKER_DIR -t $IMAGE_NAME --target $DOCKER_TARGET --build-arg $BUILD_ARG_1  --build-arg $BUILD_ARG_2 --build-arg $BUILD_ARG_3 --build-arg $BUILD_ARG_4 --build-arg $BUILD_ARG_5 --build-arg $BUILD_ARG_6 --build-arg $BUILD_ARG_7 --build-arg $BUILD_ARG_8 --build-arg $BUILD_ARG_9"

# If Docker name name space is pecified add to registry
if [ -n "$GCLOUD_AUTH" ]
 then
  REGISTRY_IMAGE="$REGISTRY/$DOCKER_REPO/$IMAGE_NAME"
else 
  REGISTRY_IMAGE="$NAMESPACE/$IMAGE_NAME"
fi

# Tag image with speciefied tag or latest
sh -c "docker tag $IMAGE_NAME $REGISTRY_IMAGE:$DOCKER_IMAGE_TAG"

# Push image to registry
sh -c "docker push $REGISTRY_IMAGE:$IMAGE_TAG"
