#!/bin/bash
HADOOP_MAJOR_VERSION=`cat /root/mapreduce/hadoop.version`
pushd /root
case "$HADOOP_MAJOR_VERSION" in
  1)
    echo "Nothing to initialize for MapReduce in Hadoop 1"
    ;;
  2) 
    wget http://archive.cloudera.com/cdh4/cdh/4/mr1-2.0.0-mr1-cdh4.2.0.tar.gz 
    tar -xvzf mr1-*.tar.gz
    rm mr1-*.tar.gz
    cp -r -n hadoop-2.0.0-mr1-cdh4.2.0/* mapreduce/
    rm -rf hadoop-2.0.0-mr1-cdh4.2.0
    ;;

  *)
     echo "ERROR: Unknown Hadoop version"
     exit -1
esac
/root/spark-ec2/copy-dir $MAPREDUCE
popd
