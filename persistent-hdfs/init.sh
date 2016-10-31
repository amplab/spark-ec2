#!/bin/bash

pushd /root > /dev/null

if [ -d "persistent-hdfs" ]; then
  echo "Persistent HDFS seems to be installed. Exiting."
  return 0
fi

case "$HADOOP_MAJOR_VERSION" in
  1)
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-1.0.4.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-1.0.4.tar.gz > /tmp/spark-ec2_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-1.0.4/ persistent-hdfs/
    cp /root/hadoop-native/* /root/persistent-hdfs/lib/native/
    ;;
  2)
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.0.0-cdh4.2.0.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-2.0.0-cdh4.2.0/ persistent-hdfs/

    # Have single conf dir
    rm -rf /root/persistent-hdfs/etc/hadoop/
    ln -s /root/persistent-hdfs/conf /root/persistent-hdfs/etc/hadoop
    cp /root/hadoop-native/* /root/persistent-hdfs/lib/native/
    ;;
  yarn)
    if [[ "$HADOOP_MINOR_VERSION" == "2.4" ]]; then
      wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.4.0.tar.gz
      echo "Unpacking Hadoop"
      tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
      rm hadoop-*.tar.gz
      mv hadoop-2.4.0/ persistent-hdfs/
    elif [[ "$HADOOP_MINOR_VERSION" == "2.6" ]]; then
      wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.6.5.tar.gz
      echo "Unpacking Hadoop"
      tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
      rm hadoop-*.tar.gz
      mv hadoop-2.6.0/ persistent-hdfs/
    elif [[ "$HADOOP_MINOR_VERSION" == "2.7" ]]; then
      wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.7.3.tar.gz
      echo "Unpacking Hadoop"
      tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
      rm hadoop-*.tar.gz
      mv hadoop-2.7.0/ persistent-hdfs/
    else
      echo "ERROR: Unknown Hadoop version"
    fi

    # Have single conf dir
    rm -rf /root/persistent-hdfs/etc/hadoop/
    ln -s /root/persistent-hdfs/conf /root/persistent-hdfs/etc/hadoop
    ;;

  *)
     echo "ERROR: Unknown Hadoop version"
     return 1
esac
/root/spark-ec2/copy-dir /root/persistent-hdfs

popd > /dev/null
