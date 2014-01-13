#!/usr/bin/env bash

# Set Spark environment variables for your site in this file. Some useful
# variables to set are:
# - MESOS_NATIVE_LIBRARY, to point to your Mesos native library (libmesos.so)
# - SCALA_HOME, to point to your Scala installation
# - SPARK_CLASSPATH, to add elements to Spark's classpath
# - SPARK_JAVA_OPTS, to add JVM options
# - SPARK_MEM, to change the amount of memory used per node (this should
#   be in the same format as the JVM's -Xmx option, e.g. 300m or 1g).
# - SPARK_LIBRARY_PATH, to add extra search paths for native libraries.

export SCALA_HOME={{scala_home}}

# Set Spark's memory per machine; note that you can also comment this out
# and have the master's SPARK_MEM variable get passed to the workers.
export SPARK_MEM={{default_spark_mem}}

# Set JVM options and Spark Java properties
SPARK_JAVA_OPTS+=" -Dspark.local.dir={{spark_local_dirs}}"
export SPARK_JAVA_OPTS

export HADOOP_HOME="/root/ephemeral-hdfs"
export SPARK_LIBRARY_PATH="/root/ephemeral-hdfs/lib/native/"
export SPARK_MASTER_IP={{active_master}}
export MASTER=`cat /root/spark-ec2/cluster-url`
export SPARK_CLASSPATH=$SPARK_CLASSPATH":/root/ephemeral-hdfs/conf"

# Bind Spark's web UIs to this machine's public EC2 hostname:
export SPARK_PUBLIC_DNS=`wget -q -O - http://169.254.169.254/latest/meta-data/public-hostname`

# Set a high ulimit for large shuffles
ulimit -n 1000000
