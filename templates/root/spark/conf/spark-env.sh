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

export SCALA_HOME=/root/scala-2.10.3
export MESOS_NATIVE_LIBRARY=/usr/local/lib/libmesos.so

# Set Spark's memory per machine; note that you can also comment this out
# and have the master's SPARK_MEM variable get passed to the workers.
export SPARK_MEM={{default_spark_mem}}

# Set JVM options and Spark Java properties
SPARK_JAVA_OPTS+=" -Dspark.local.dir={{spark_local_dirs}}"
export SPARK_JAVA_OPTS

export SPARK_MASTER_IP={{active_master}}

export SPARK_CLASSPATH+=:/root/tachyon/target/tachyon-0.4.0-jar-with-dependencies.jar
export ADD_JARS=/root/tachyon/target/tachyon-0.4.0-jar-with-dependencies.jar

# Use the Spark cluster url is $MASTER is not set
export MASTER=${MASTER-`cat /root/spark-ec2/cluster-url`}
export SPARK_EXECUTOR_URI=hdfs://{{active_master}}:9000/spark.tar.gz
