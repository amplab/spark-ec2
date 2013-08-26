#!/bin/bash

mkdir -p /mnt/mesos-logs
mkdir -p /mnt/mesos-work

for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS root@$node "mkdir -p /mnt/mesos-logs /mnt/mesos-work" & sleep 0.3
done
wait

# Start zookeeper first
ZOO_LOG_DIR=/mnt /root/zookeeper-3.4.5/bin/zkServer.sh stop
# Clear all zookeeper state
rm -rf /mnt/zookeeper/*
ZOO_LOG_DIR=/mnt /root/zookeeper-3.4.5/bin/zkServer.sh start

sleep 2

/root/spark-ec2/mesos/run-master.sh

sleep 2

echo "Starting Mesos slaves"

# Finally start mesos slaves
for node in $SLAVES; do
  ssh -t $SSH_OPTS root@$node "/root/spark-ec2/mesos/run-slave.sh" & sleep 0.3
done
wait
