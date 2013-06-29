#!/bin/bash

# Setup persistent-hdfs
mkdir -p /mnt/persistent-hdfs/logs

if [[ -e /vol/persistent-hdfs ]] ; then
  chmod -R 755 /vol/persistent-hdfs
fi
