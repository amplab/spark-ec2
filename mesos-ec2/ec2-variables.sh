#!/bin/bash

# These variables are automatically filled in by the mesos-ec2 script.
export MESOS_MASTERS="ec2-107-22-79-196.compute-1.amazonaws.com"
export MESOS_SLAVES="ec2-107-22-111-247.compute-1.amazonaws.com"
export MESOS_ZOO_LIST="NONE"
export MESOS_HDFS_DATA_DIRS="/mnt/ephemeral-hdfs/data,/mnt2/ephemeral-hdfs/data"
export MESOS_MAPRED_LOCAL_DIRS="/mnt/hadoop/mrlocal,/mnt2/hadoop/mrlocal"
