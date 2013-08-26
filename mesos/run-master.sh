#!/bin/bash

echo "Starting Mesos master"
# Killing any existing master
killall mesos-master

# NOTE: We need this to make sure the slaves flag is not used from
# ec2-variables.sh, so set it to * before running mesos-master

MESOS_SLAVES="*" nohup mesos-master \
  --zk=zk://`cat /root/spark-ec2/masters`:2181/mesos \
  --log_dir=/mnt/mesos-logs \
  < /dev/null >/mnt/mesos-logs/mesos-master.out 2>&1 &
