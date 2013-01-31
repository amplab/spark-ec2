#!/bin/bash

pushd /root
git clone git://github.com/mesos/spark.git 
pushd /root/spark
./sbt/sbt publish-local

popd
popd

/root/spark-ec2/copy-dir /root/spark
