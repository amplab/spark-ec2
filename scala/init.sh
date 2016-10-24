#!/bin/bash

pushd /root > /dev/null

if [ -d "scala" ]; then
  echo "Scala seems to be installed. Exiting."
  return 0
fi

SCALA_VERSION="2.10.3"

if [[ "0.7.3 0.8.0 0.8.1" =~ $SPARK_VERSION ]]; then
  SCALA_VERSION="2.9.3"
  wget http://s3.amazonaws.com/spark-related-packages/scala-$SCALA_VERSION.tgz
elif [[ "2.0.0" =~ $SPARK_VERSION ]]; then
  SCALA_VERSION="2.11.8"
  wget http://s3.amazonaws.com/spark-related-packages/scala-$SCALA_VERSION.tgz
else
  wget http://s3.amazonaws.com/spark-related-packages/scala-$SCALA_VERSION.tgz
fi

echo "Unpacking Scala"
tar xvzf scala-*.tgz > /tmp/spark-ec2_scala.log
rm scala-*.tgz
mv `ls -d scala-* | grep -v ec2` scala

popd > /dev/null
