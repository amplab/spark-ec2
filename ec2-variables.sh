#!/bin/bash

# These variables should be set before running setup.sh.
# TODO: These variables are called MESOS_* for backwards compatibility. Remove
# the prefix once we change spark_ec2.py
export MESOS_MASTERS="ec2-107-22-79-196.compute-1.amazonaws.com"
export MESOS_SLAVES="ec2-107-22-111-247.compute-1.amazonaws.com"
export MESOS_HDFS_DATA_DIRS="/mnt/ephemeral-hdfs/data,/mnt2/ephemeral-hdfs/data"
export MESOS_MAPRED_LOCAL_DIRS="/mnt/hadoop/mrlocal,/mnt2/hadoop/mrlocal"
export MESOS_ZOO_LIST="NONE"
export SWAP_MB=1024

# Supported modules
#   spark
#   ephemeral-hdfs
#   persistent-hdfs
#   mesos
export MODULES="spark ephemeral-hdfs mesos"

# Other variables used in scripts
# export SPARK_LOCAL_DIRS
# export MESOS_DOWNLOAD_METHOD
