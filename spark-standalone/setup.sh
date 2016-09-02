#!/bin/bash

BIN_FOLDER="~/spark/sbin"

if [[ "0.7.3 0.8.0 0.8.1" =~ $SPARK_VERSION ]]; then
  BIN_FOLDER="~/spark/bin"
fi

# Copy the slaves to spark conf
cp ~/spark-ec2/slaves ~/spark/conf/
~/spark-ec2/copy-dir ~/spark/conf

# Set cluster-url to standalone master
echo "spark://""`cat ~/spark-ec2/masters`"":7077" > ~/spark-ec2/cluster-url
~/spark-ec2/copy-dir ~/spark-ec2

# The Spark master seems to take time to start and workers crash if
# they start before the master. So start the master first, sleep and then start
# workers.

# Stop anything that is running
$BIN_FOLDER/stop-all.sh

sleep 2

# Start Master
$BIN_FOLDER/start-master.sh

# Pause
sleep 20

# Start Workers
$BIN_FOLDER/start-slaves.sh
