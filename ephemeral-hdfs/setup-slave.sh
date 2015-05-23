#!/bin/bash

# Setup ephemeral-hdfs
mkdir -p /mnt/ephemeral-hdfs/logs
mkdir -p /mnt/hadoop-logs

# Setup yarn logs, local dirs
mkdir -p /mnt/yarn-local
mkdir -p /mnt/yarn-logs

# Create Hadoop and HDFS directories in a given parent directory
# (for example /mnt, /mnt2, and so on)
function create_hadoop_dirs {
  location=$1
  if [[ -e $location ]]; then
    mkdir -p $location/ephemeral-hdfs $location/hadoop/tmp
    chmod -R 755 $location/ephemeral-hdfs
    mkdir -p $location/hadoop/mrlocal $location/hadoop/mrlocal2
  fi
}

# Set up Hadoop and Mesos directories in /mnt
create_hadoop_dirs /mnt
create_hadoop_dirs /mnt2
create_hadoop_dirs /mnt3
create_hadoop_dirs /mnt4
