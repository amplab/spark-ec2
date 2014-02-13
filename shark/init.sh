#!/bin/bash

pushd /root

if [ -d "shark" ]; then
  echo "Shark seems to be installed. Exiting."
  return
fi

# Github tag:
if [[ "$SHARK_VERSION" == *\|* ]]
then
  # Not yet supported
  echo ""
# Pre-package shark version
else
  case "$SHARK_VERSION" in
    0.7.0)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/shark-0.7.0-hadoop1-bin.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/shark-0.7.0-hadoop2-bin.tgz
      fi
      ;;    
    0.7.1)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/shark-0.7.1-hadoop1-bin.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/shark-0.7.1-hadoop2-bin.tgz
      fi
      ;;    
    0.8.0)
      wget http://s3.amazonaws.com/spark-related-packages/hive-0.9.0-bin.tgz
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/shark-0.8.0-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/shark-0.8.0-bin-cdh4.tgz
      fi
      ;;
    0.8.1)
      wget http://s3.amazonaws.com/spark-related-packages/hive-0.9.0-bin.tgz
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/shark-0.8.1-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/shark-0.8.1-bin-cdh4.tgz
      fi
      ;;
    *)
      echo "ERROR: Unknown Shark version"
      return
  esac

  echo "Unpacking Shark"
  tar xvzf shark-*.tgz > /tmp/spark-ec2_shark.log
  rm shark-*.tgz
  mv `ls -d shark-*` shark

  if stat -t hive*tgz >/dev/null 2>&1; then
    echo "Unpacking Hive"
    # NOTE: don't rename this because currently HIVE_HOME is set to "hive-0.9-bin".
    #       Could be renamed to "hive" in the future to support multiple hive
    #       versions associated with different shark versions.
    tar xvzf hive-*.tgz > /tmp/spark-ec2_hive.log
    rm hive-*.tgz
  fi
fi

popd
