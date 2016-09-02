#!/bin/bash

PERSISTENT_HDFS=~/persistent-hdfs
USER=`whoami`

pushd ~/spark-ec2/persistent-hdfs > /dev/null
source ./setup-slave.sh

for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS $USER@$node "~/spark-ec2/persistent-hdfs/setup-slave.sh" & sleep 0.3
done
wait

~/spark-ec2/copy-dir $PERSISTENT_HDFS/conf

if [[ ! -e /vol/persistent-hdfs/dfs/name ]] ; then
  echo "Formatting persistent HDFS namenode..."
  $PERSISTENT_HDFS/bin/hadoop namenode -format
fi

echo "Persistent HDFS installed, won't start by default..."

popd > /dev/null
