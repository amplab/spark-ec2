#!/bin/bash

# Copy the slaves to spark conf
cp /root/spark-ec2/slaves /root/spark/conf/
/root/spark-ec2/copy-dir /root/spark/conf

# Set cluster-url to standalone master
echo "spark://""`cat /root/spark-ec2/masters`"":7077" > /root/spark-ec2/cluster-url
cp -f /root/spark-ec2/cluster-url /root/mesos-ec2/cluster-url
/root/spark-ec2/copy-dir /root/spark-ec2
/root/spark-ec2/copy-dir /root/mesos-ec2

# The Spark master seems to take time to start and workers crash if
# they start before the master. So start the master first, sleep and then start
# workers.

# Stop anything that is running
/root/spark/bin/stop-all.sh

sleep 2

# Start Master
/root/spark/bin/start-master.sh

# Pause
sleep 20

# Start Workers
/root/spark/bin/start-slaves.sh
