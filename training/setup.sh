#!/bin/bash

pushd /root

ssh-keyscan -H github.com >> /root/.ssh/known_hosts
rm -rf training
git clone git@github.com:amplab/training.git

pushd training
cp -r streaming /root/
cp -r kmeans /root/
# TODO: Move java-app-template, scala-app-template also here ?

popd
popd

/root/spark-ec2/copy-dir /root/streaming
/root/spark-ec2/copy-dir /root/kmeans

# Training specific hacks

# Check if Hadoop version is 0.205.0 in project/SparkBuild.scala
# if not rebuild spark

HADOOP_VERSION=`cat /root/spark/project/SparkBuild.scala | grep "val HADOOP_VERSION =" | grep -v "//" | awk '{print $NF}' | tr -d \"`
if [[ "$HADOOP_VERSION" != "0.20.205.0" ]]; then
  echo "Setting hadoop version to 0.20.205.0 ..."
  sed -i 's/val HADOOP_VERSION = \"'$HADOOP_VERSION'\"/val HADOOP_VERSION = \"0.20.205.0\"/g' /root/spark/project/SparkBuild.scala
  pushd /root/spark
  ./sbt/sbt clean publish-local
  /root/spark-ec2/copy-dir /root/spark
  popd
fi
