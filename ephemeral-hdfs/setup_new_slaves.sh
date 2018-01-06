#!/bin/bash

EPHEMERAL_HDFS=/root/ephemeral-hdfs

# Set hdfs url to make it easier
export HDFS_URL="hdfs://$PUBLIC_DNS:9000"

pushd /root/spark-ec2/ephemeral-hdfs > /dev/null

for node in $NEW_SLAVES; do
  echo $node
  ssh -t -t $SSH_OPTS root@$node "/root/spark-ec2/ephemeral-hdfs/setup-slave.sh" & sleep 0.3
done
wait

/root/spark-ec2/copy-dir $EPHEMERAL_HDFS/conf

echo "Starting ephemeral HDFS..."

# This is different depending on version.
case "$HADOOP_MAJOR_VERSION" in
  1)
    $EPHEMERAL_HDFS/bin/start-dfs.sh
    ;;
  2)
    $EPHEMERAL_HDFS/sbin/start-dfs.sh
    ;;
  yarn) 
    $EPHEMERAL_HDFS/sbin/start-dfs.sh
    echo "Starting YARN"
    $EPHEMERAL_HDFS/sbin/start-yarn.sh
    ;;
  *)
     echo "ERROR: Unknown Hadoop version"
     return -1
esac

popd > /dev/null
