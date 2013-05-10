#!/bin/bash
SHARK_VERSION=`cat /root/shark/shark.version`
HADOOP_MAJOR_VERSION=`cat /root/spark/hadoop.version`

pushd /root

# Github tag:
if [[ "$SHARK_VERSION" == *\|* ]]
then
  pushd shark
  git init
  repo=`python -c "print '$SHARK_VERSION'.split('|')[0]"`
  git_hash=`python -c "print '$SHARK_VERSION'.split('|')[1]"`
  git remote add origin $repo
  git fetch origin
  git checkout $git_hash
  sbt/sbt clean products
  popd

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

  tar xvzf shark-*.tgz
  rm shark-*.tgz
  # Copy to 'shark' folder and delete shark-X.X.X folder
  ls -d */ |grep shark- | xargs -I {}  bash -c "cp -r {}* shark/ && rm -rf {}"
fi

popd
