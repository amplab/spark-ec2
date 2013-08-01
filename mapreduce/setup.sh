#!/bin/bash
MAPREDUCE=/root/mapreduce

mkdir -p /mnt/mapreduce/logs
for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS root@$node "mkdir -p /mnt/mapreduce/logs && chown hadoop:hadoop /mnt/mapreduce/logs && chown hadoop:hadoop /mnt/mapreduce" & sleep 0.3
done
wait

chown hadoop:hadoop /mnt/mapreduce -R
/root/spark-ec2/copy-dir $MAPREDUCE/conf
