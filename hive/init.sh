#!/bin/bash

pushd /root
git clone git://github.com/amplab/hive.git 
pushd /root/hive
ant package
echo "export HIVE_HOME=/root/hive" >> ~/.bash_profile

popd
popd

/root/spark-ec2/copy-dir /root/hive
/root/spark-ec2/copy-dir /root/.bash_profile
