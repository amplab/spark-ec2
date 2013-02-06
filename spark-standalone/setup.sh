#!/bin/bash

cp /root/spark-ec2/slaves /root/spark/conf/

# Set cluster-url to standalone master
echo "spark://""`cat /root/spark-ec2/masters`"":7077" > /root/spark-ec2/cluster-url
cp -f /root/spark-ec2/cluster-url /root/mesos-ec2/cluster-url
/root/spark-ec2/copy-dir /root/spark/conf

# The Spark master seems to take time to start and workers crash if
# they start before the master. Try to see if waiting makes the master start up
# more reliably.
sleep 15

/root/spark/bin/start-all.sh

sleep 15
