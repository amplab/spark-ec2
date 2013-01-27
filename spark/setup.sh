#!/bin/bash

echo "Setting up Spark config files..."
# TODO: This currently overwrites whatever the user wrote there; on
# the other hand, we also don't want to leave an old file created by
# us because it would have the wrong hostname for HDFS etc
mkdir -p /root/spark/conf
chmod u+x /root/spark/conf/spark-env.sh

echo "Deploying Spark config files..."
/root/spark-ec2/copy-dir /root/spark/conf

# Add stuff for standalone mode here, using an environment variable
