#!/bin/bash

pushd /root
wget http://archive.apache.org/dist/hadoop/common/hadoop-0.20.205.0/hadoop-0.20.205.0.tar.gz
tar -xf hadoop-0.20.205.0.tar.gz
mv hadoop-0.20.205.0 ephemeral-hdfs

sed -i 's/-jvm server/-server/g' /root/ephemeral-hdfs/bin/hadoop

/root/spark-ec2/copy-dir /root/ephemeral-hdfs
popd
