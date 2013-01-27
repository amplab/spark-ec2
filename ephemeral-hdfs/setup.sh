#!/bin/bash

EPHEMERAL_HDFS=/root/ephemeral-hdfs
pushd $EPHEMERAL_HDFS

source ./setup-slave.sh

for node in $SLAVES $OTHER_MASTERS; do
  echo $node
  ssh -t $SSH_OPTS root@$node "/root/spark-ec2/ephemeral-hdfs/setup-slave.sh" & sleep 0.3
done

/root/spark-ec2/copy-dir $EPHEMERAL_HDFS/conf

echo "Formatting ephemeral HDFS namenode..."
$EPHEMERAL_HDFS/bin/hadoop namenode -format

echo "Starting ephemeral HDFS..."
$EPHEMERAL_HDFS/bin/start-dfs.sh

popd
