#!/bin/bash

# Set HADOOP_HOME variable to allow slaves to get executors from HDFS
export HADOOP_HOME=/root/ephemeral-hdfs

ulimit -n 8192

CPUS=`grep processor /proc/cpuinfo | wc -l`
MEM_KB=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
MEM=$[(MEM_KB - 1024 * 1024) / 1024]

# Kill any slaves already running
killall mesos-slave

echo "Starting mesos slave on `hostname`"


nohup mesos-slave \
  --master=zk://`cat /root/spark-ec2/masters`:2181/mesos \
  --resources="cpus:$CPUS;mem:$MEM" \
  --work_dir=/mnt/mesos-work \
  --log_dir=/mnt/mesos-logs \
  --hadoop_home=$HADOOP_HOME \
  --no-switch_user >/mnt/mesos-logs/mesos-slave.out 2>&1 &
