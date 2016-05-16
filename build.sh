#!/bin/sh
#
# Build armv8 Ubuntu base image for docker (on x86 as well as armhf machines)
# - image will be tagged with the chosen version
#
# Synopsis: build.sh [VERSION] [IMAGE NAME]
#
# Defaults: build.sh 16.04 <YOUR-DOCKER-USER>/armhf-ubuntu

# Fail on error
set -e

VERSION=${1:-16.04}
ARCHIVE_NAME=ubuntu-base-$VERSION-core-armhf.tar
BASE_IMAGE_URL=http://cdimage.ubuntu.com/ubuntu-base/releases/$VERSION/release/${ARCHIVE_NAME}.gz

# Use given image name or the default one (with your username)
if [ -n "$2" ]; then
  IMAGE_NAME=$2:$VERSION
else
  DOCKER_USER=michaelcoll
  IMAGE_NAME=$DOCKER_USER/armhf-ubuntu:$VERSION
fi

echo Building $IMAGE_NAME

# Unzip Ubuntu core image
wget -c -P /tmp $BASE_IMAGE_URL
gunzip -f -k /tmp/${ARCHIVE_NAME}.gz

# Add files to base image and import it
sudo docker import - $IMAGE_NAME < /tmp/${ARCHIVE_NAME}
rm /tmp/${ARCHIVE_NAME} /tmp/${ARCHIVE_NAME}.gz -fR

echo "Successfully built image $IMAGE_NAME."
