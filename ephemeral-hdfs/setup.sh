#!/bin/bash

EPHEMERAL_HDFS=/root/ephemeral-hdfs

# Set hdfs url to make it easier
HDFS_URL="hdfs://$PUBLIC_DNS:9000"
echo "export HDFS_URL=$HDFS_URL" >> ~/.bash_profile

pushd /root/spark-ec2/ephemeral-hdfs
source ./setup-slave.sh

for node in $SLAVES $OTHER_MASTERS; do
  echo $node
  ssh -t -t $SSH_OPTS root@$node "/root/spark-ec2/ephemeral-hdfs/setup-slave.sh" & sleep 0.3
done
wait

/root/spark-ec2/copy-dir $EPHEMERAL_HDFS/conf

NAMENODE_DIR=/mnt/ephemeral-hdfs/dfs/name

if [ -f "$NAMENODE_DIR/current/VERSION" ] && [ -f "$NAMENODE_DIR/current/fsimage" ]; then
  echo "Hadoop namenode appears to be formatted: skipping"
else
  echo "Formatting ephemeral HDFS namenode..."
  $EPHEMERAL_HDFS/bin/hadoop namenode -format
fi

echo "Starting ephemeral HDFS..."
# This is different depending on version. Simple hack: just try both.
$EPHEMERAL_HDFS/sbin/start-dfs.sh
$EPHEMERAL_HDFS/bin/start-dfs.sh

popd
