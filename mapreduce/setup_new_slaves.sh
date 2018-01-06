#!/bin/bash
MAPREDUCE=/root/mapreduce

for node in $NEW_SLAVES; do
  ssh -t $SSH_OPTS root@$node "mkdir -p /mnt/mapreduce/logs && chown hadoop:hadoop /mnt/mapreduce/logs && chown hadoop:hadoop /mnt/mapreduce" & sleep 0.3
done
wait

/root/spark-ec2/copy-dir $MAPREDUCE/conf
