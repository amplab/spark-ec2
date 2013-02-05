#!/bin/bash

pushd /root

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
