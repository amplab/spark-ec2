#!/bin/bash

# These variables should be set before running setup.sh.
# TODO: These variables are called MESOS_* for backwards compatibility. Remove
# the prefix once we change spark_ec2.py
export MESOS_MASTERS=""
export MESOS_SLAVES=""
export MESOS_HDFS_DATA_DIRS="/mnt/ephemeral-hdfs/data,/mnt2/ephemeral-hdfs/data"
export MESOS_MAPRED_LOCAL_DIRS="/mnt/hadoop/mrlocal,/mnt2/hadoop/mrlocal"
export MESOS_ZOO_LIST="NONE"
export SWAP_MB=1024

# Supported modules
#   ephemeral-hdfs
#   persistent-hdfs
#   mesos
#   spark-standalone
export MODULES="ephemeral-hdfs mesos"

# Other variables used in scripts
# export MESOS_SPARK_LOCAL_DIRS - used to set local directories for spark
# export MESOS_DOWNLOAD_METHOD  - used to control how mesos is built
