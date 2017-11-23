#!/bin/bash
MAPREDUCE=~/mapreduce
USER=`whoami`

mkdir -p /mnt/mapreduce/logs
for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS $USER@$node "mkdir -p /mnt/mapreduce/logs && chown hadoop:hadoop /mnt/mapreduce/logs && chown hadoop:hadoop /mnt/mapreduce" & sleep 0.3
done
wait

chown hadoop:hadoop /mnt/mapreduce -R
~/spark-ec2/copy-dir $MAPREDUCE/conf
