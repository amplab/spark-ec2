#!/bin/bash

pushd /root > /dev/null

if [ -d "redis-cli" ]; then
  echo "Redis seems to be installed. Exiting."
  return 0
fi

yum -y --enablerepo=epel install redis
yum -y install emacs.x86_64

popd > /dev/null
