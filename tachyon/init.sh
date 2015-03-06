#!/bin/bash

pushd /root > /dev/null

if [ -d "tachyon" ]; then
  echo "Tachyon seems to be installed. Exiting."
  return 0
fi

TACHYON_VERSION=0.5.0

# Github tag:
if [[ "$TACHYON_VERSION" == *\|* ]]
then
  # Not yet supported
  echo ""
# Pre-package tachyon version
else
  case "$TACHYON_VERSION" in
    0.3.0)
      wget https://s3.amazonaws.com/Tachyon/tachyon-0.3.0-bin.tar.gz
      ;;
    0.4.0)
      wget https://s3.amazonaws.com/Tachyon/tachyon-0.4.0-bin.tar.gz
      ;;
    0.4.1)
      wget https://s3.amazonaws.com/Tachyon/tachyon-0.4.1-bin.tar.gz
      ;;
    0.5.0)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget https://s3.amazonaws.com/Tachyon/tachyon-0.5.0-bin.tar.gz
      else
        wget https://s3.amazonaws.com/Tachyon/tachyon-0.5.0-cdh4-bin.tar.gz
      fi
      ;;
    0.6.0)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget https://s3.amazonaws.com/Tachyon/tachyon-0.6.0-bin.tar.gz
      else
        wget https://s3.amazonaws.com/Tachyon/tachyon-0.6.0-cdh4-bin.tar.gz
      fi
      ;;
    *)
      echo "ERROR: Unknown Tachyon version"
      return -1
  esac

  echo "Unpacking Tachyon"
  tar xvzf tachyon-*.tar.gz > /tmp/spark-ec2_tachyon.log
  rm tachyon-*.tar.gz
  mv `ls -d tachyon-*` tachyon
fi

popd > /dev/null
