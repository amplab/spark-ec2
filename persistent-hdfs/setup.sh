#!/bin/bash

PERSISTENT_HDFS=/root/persistent-hdfs

/root/spark-ec2/copy-dir $PERSISTENT_HDFS

mkdir -p /mnt/persistent-hdfs/logs
for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS root@$node "mkdir -p /mnt/persistent-hdfs/logs" & sleep 0.3
done
wait

/root/spark-ec2/copy-dir $PERSISTENT_HDFS/etc/hadoop

if [[ ! -e /vol/persistent-hdfs/dfs/name ]] ; then
  echo "Formatting persistent HDFS namenode..."
  $PERSISTENT_HDFS/bin/hadoop namenode -format
fi

echo "Persistent HDFS installed, won't start by default..."
