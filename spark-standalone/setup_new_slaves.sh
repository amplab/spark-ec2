#!/bin/bash

BIN_FOLDER="/root/spark/sbin"

if [[ "0.7.3 0.8.0 0.8.1" =~ $SPARK_VERSION ]]; then
  BIN_FOLDER="/root/spark/bin"
fi

# Copy the slaves to spark conf
cp /root/spark-ec2/slaves /root/spark/conf/
/root/spark-ec2/copy-dir /root/spark/conf

# Set cluster-url to standalone master
echo "spark://""`cat /root/spark-ec2/masters`"":7077" > /root/spark-ec2/cluster-url
/root/spark-ec2/copy-dir /root/spark-ec2

# Start Workers
$BIN_FOLDER/start-slaves.sh
