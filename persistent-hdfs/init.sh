#!/bin/bash

pushd /root
wget -S -N http://archive.apache.org/dist/hadoop/common/hadoop-0.20.205.0/hadoop-0.20.205.0.tar.gz
tar -xf hadoop-0.20.205.0.tar.gz
mv hadoop-0.20.205.0 persistent-hdfs

sed -i 's/-jvm server/-server/g' /root/persistent-hdfs/bin/hadoop

/root/spark-ec2/copy-dir /root/persistent-hdfs
popd
