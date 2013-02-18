#!/bin/bash

pushd /root/spark-ec2/spark-standalone

# Copy the slaves to spark conf
cp /root/spark-ec2/slaves /root/spark/conf/

# Set cluster-url to standalone master
echo "spark://""`cat /root/spark-ec2/masters`"":7077" > /root/spark-ec2/cluster-url
cp -f /root/spark-ec2/cluster-url /root/mesos-ec2/cluster-url
/root/spark-ec2/copy-dir /root/spark/conf

# The Spark master seems to take time to start and workers crash if
# they start before the master. Retry a few times with a health check

NUM_RETRIES=3
STATUS=1
ATTEMPTS=1

while [ $STATUS -ne 0 ] && [ $ATTEMPTS -le $NUM_RETRIES ]
do
  echo "Starting Spark...Attempt $ATTEMPTS/$NUM_RETRIES" 
  /root/spark/bin/stop-all.sh
  sleep 2
  /root/spark/bin/start-all.sh
  sleep 5
  python ./check_spark.py `cat /root/spark-ec2/masters` `wc -l /root/spark/conf/slaves`
  STATUS=$?
  ATTEMPTS=$(( $ATTEMPTS + 1 ))
done

popd
