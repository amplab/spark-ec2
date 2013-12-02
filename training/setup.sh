#!/bin/bash

pushd /root

# Make sure screen is installed in the master node
yum install -y screen

# Mount ampcamp-data volume
mount -t ext4 /dev/sdf /ampcamp-data

# Clone and copy training repo
ssh-keyscan -H github.com >> /root/.ssh/known_hosts
rm -rf training
git clone https://github.com/amplab/training.git

pushd training
/root/spark-ec2/copy-dir /root/training

ln -T -f -s /root/training/streaming /root/streaming
ln -T -f -s /root/training/kmeans /root/kmeans
ln -T -f -s /root/training/java-app-template /root/java-app-template
ln -T -f -s /root/training/scala-app-template /root/scala-app-template

# Add hdfs to the classpath
cp /root/ephemeral-hdfs/conf/core-site.xml /root/spark/conf/
popd

popd
