#!/bin/bash

mkdir -p /mnt/mesos-logs
mkdir -p /mnt/mesos-work

for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS root@$node "mkdir -p /mnt/mesos-logs /mnt/mesos-work" & sleep 0.3
done
wait

# Start zookeeper first
ZOO_LOG_DIR=/mnt /root/zookeeper-3.4.5/bin/zkServer.sh start

# Start a mesos master now
nohup mesos-master \
--zk=zk://`cat /root/spark-ec2/masters`:2181/mesos \
--log_dir=/mnt/mesos-logs >/dev/null 2>&1 &

# Finally start mesos slaves
for node in $SLAVES; do
  ssh -t $SSH_OPTS root@node "/root/spark-ec2/mesos/run-slave.sh" & sleep 0.3
done
wait
