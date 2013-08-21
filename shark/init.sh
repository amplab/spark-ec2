#!/bin/bash

pushd /root

if [ -d "shark" ]; then
  echo "Shark seems to be installed. Exiting."
  exit 0
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
        wget http://d3kbcqa49mib13.cloudfront.net/shark-0.7.0-hadoop1-bin.tgz
      else
        wget http://d3kbcqa49mib13.cloudfront.net/shark-0.7.0-hadoop2-bin.tgz
      fi
      ;;    
    *)
      echo "ERROR: Unknown Shark version"
      exit -1
  esac

  echo "Unpacking Shark"
  tar xvzf shark-*.tgz > /tmp/spark-ec2_shark.log
  rm shark-*.tgz
  mv `ls -d shark-*` shark
fi

popd
