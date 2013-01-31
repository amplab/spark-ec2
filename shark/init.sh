#!/bin/bash

pushd /root
git clone git://github.com/amplab/shark.git 
pushd /root/shark
export HIVE_HOME=/root/hive/build/dist/
./sbt/sbt package

popd
popd

/root/spark-ec2/copy-dir /root/shark
