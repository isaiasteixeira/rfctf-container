#!/bin/sh
# This script is used before creating the game image to clean up the master

# stop all running docker containers
if [ -n "$(docker ps -a -q)" ]; then
  docker stop $(docker ps -a -q)
fi
# remove any stopped containers which weren't removed already
if [ -n "$(docker ps -a -q)" ]; then
  docker rm $(docker ps -a -q)
fi

# pull latest images for everything
for image in $(docker image ls | grep '^rfhs' | awk '{print $1}'); do
  docker pull "${image}"
done
# cleanup untagged docker images
if [ -n "$(docker images | grep "<none>" | awk '{print $3}')" ]; then
  docker rmi $(docker images | grep "<none>" | awk '{print $3}')
fi

# cleanup unneeded gentoo files leftover from upgrading
if [ -x "$(command -v portageq 2>&1)" ]; then
  rm -rf "$(portageq envvar DISTDIR)"/*
  rm -rf "$(portageq envvar PKGDIR)"/*
fi

# ensure shared-persistent_storage is empty
if [ -d '/var/wctf/shared_persistent_storage/*' ]; then
  rm -rf /var/wctf/shared_persistent_storage/*
fi

#wipe all the container logs
[ -d '/var/wctf/contestant' ] && find /var/wctf/contestant/ -type f -not -name authorized_keys -exec rm -rf {} \;
[ -d '/var/log/rfhs-rfctf' ] && find /var/log/rfhs-rfctf/ -type f -not -name authorized_keys -exec rm -rf {} \;

# clean cloud init
[ -x "$(command -v cloud-init 2>&1)" ] && cloud-init clean
