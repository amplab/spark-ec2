#!/bin/bash
SPARK_VERSION=`cat /root/spark/spark.version`
HADOOP_MAJOR_VERSION=`cat /root/spark/hadoop.version`

pushd /root

# Github tag:
if [[ "$SPARK_VERSION" == *\|* ]]
then
  pushd spark
  git init
  repo=`python -c "print '$SPARK_VERSION'.split('|')[0]"` 
  git_hash=`python -c "print '$SPARK_VERSION'.split('|')[1]"`
  git remote add origin $repo
  git fetch origin
  git checkout $git_hash
  sbt/sbt clean publish-local
  popd

# Pre-packaged spark version:
else 
  case "$SPARK_VERSION" in
    0.7.2)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://spark-project.org/files/spark-0.7.2-prebuilt-hadoop1.tgz
      else
        wget http://spark-project.org/files/spark-0.7.2-prebuilt-cdh4.tgz
      fi
      ;;    
    *)
      echo "ERROR: Unknown Spark version"
      exit -1
  esac

  tar xvzf spark-*.tgz
  rm spark-*.tgz
  # Copy to 'spark' folder and delete spark-X.X.X folder
  ls -d */ |grep spark- |grep -v ec2 | xargs -I {}  bash -c "cp -r {}* spark/ && rm -rf {}"
fi

popd
