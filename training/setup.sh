#!/bin/bash

pushd /root

# Mount ampcamp-data volume
mount -t ext4 /dev/sdf /ampcamp-data

# Clone and copy training repo
ssh-keyscan -H github.com >> /root/.ssh/known_hosts
rm -rf training
git clone https://github.com/amplab/training.git

pushd training
/root/spark-ec2/copy-dir /root/training

ln -T -f -s /root/training/streaming /root/streaming
#ln -T -f -s /root/training/kmeans /root/kmeans
ln -T -f -s /root/training/java-app-template /root/java-app-template
ln -T -f -s /root/training/scala-app-template /root/scala-app-template

# DRY RUN HACK
# Copy spark-env.sh and slave to 0.7.1 from master
#cp /root/spark/conf/slaves /root/spark-0.7.1/conf/
#cp /root/spark/conf/spark-env.sh /root/spark-0.7.1/conf/
#/root/spark-ec2/copy-dir /root/spark-0.7.1/conf

# Add hdfs to the classpath
cp /root/ephemeral-hdfs/conf/core-site.xml /root/spark/conf/
popd

# Build MLI assembly
#
pushd /root/MLI
git remote set-url origin https://github.com/amplab/MLI.git
git pull
./sbt/sbt assembly
/root/spark-ec2/copy-dir /root/MLI
popd

# Pull and rebuild blinkdb
pushd /root/hive_blinkdb
git pull
ant package
/root/spark-ec2/copy-dir /root/hive_blinkdb
popd

pushd /root/blinkdb
#git fetch --all
#git checkout origin/alpha-0.1.0
#git checkout -b alpha-0.1.0
git pull
./sbt/sbt clean package

# Uncomment to make blinkdb use Spark 0.7.1
# sed -i 's/export SPARK_HOME.*/export SPARK_HOME=\"\/root\/spark-0.7.1\"/g conf/shark-env.sh

/root/spark-ec2/copy-dir /root/blinkdb
popd

# Tar and copy hadoop, spark
pushd /root
echo "Copying Hadoop executor for Mesos"
tar czf /mnt/ephemeral-hdfs.tar.gz ephemeral-hdfs
~/ephemeral-hdfs/bin/hadoop fs -put /mnt/ephemeral-hdfs.tar.gz /
echo "Copying Spark executor for Mesos"
tar czf /mnt/spark.tar.gz spark
~/ephemeral-hdfs/bin/hadoop fs -put /mnt/spark.tar.gz /
rm /mnt/spark.tar.gz
rm /mnt/ephemeral-hdfs.tar.gz
popd

#echo "Starting Hadoop Job tracker on Mesos"
#nohup ~/ephemeral-hdfs/bin/hadoop jobtracker 2>&1 >/mnt/job-tracker.out &

popd
