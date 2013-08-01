#!/bin/bash

pushd /root

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
        wget http://spark-project.org/files/shark/shark-0.7.0-hadoop1-bin.tgz
      else
        wget http://spark-project.org/files/shark/shark-0.7.0-hadoop2-bin.tgz
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
