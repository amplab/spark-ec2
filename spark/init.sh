#!/bin/bash

pushd /root > /dev/null

if [ -d "spark" ]; then
  echo "Spark seems to be installed. Exiting."
  return
fi

# Github tag:
if [[ "$SPARK_VERSION" == *\|* ]]
then
  mkdir spark
  pushd spark > /dev/null
  git init
  repo=`python -c "print '$SPARK_VERSION'.split('|')[0]"` 
  git_hash=`python -c "print '$SPARK_VERSION'.split('|')[1]"`
  git remote add origin $repo
  git fetch origin
  git checkout $git_hash
  sbt/sbt clean assembly
  sbt/sbt publish-local
  popd > /dev/null

# Pre-packaged spark version:
else 
  case "$SPARK_VERSION" in
    0.7.3)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.7.3-prebuilt-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.7.3-prebuilt-cdh4.tgz
      fi
      ;;    
    0.8.0)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.8.0-incubating-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.8.0-incubating-bin-cdh4.tgz
      fi
      ;;    
    0.8.1)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.8.1-incubating-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.8.1-incubating-bin-cdh4.tgz
      fi
      ;;    
    0.9.0)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.9.0-incubating-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.9.0-incubating-bin-cdh4.tgz
      fi
      ;;
    0.9.1)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.9.1-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.9.1-bin-cdh4.tgz
      fi
      ;;
    0.9.2)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.9.2-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-0.9.2-bin-cdh4.tgz
      fi
      ;;
    1.0.0)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.0.0-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.0.0-bin-cdh4.tgz
      fi
      ;;
    1.0.1)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.0.1-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.0.1-bin-cdh4.tgz
      fi
      ;;
    1.0.2)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.0.2-bin-hadoop1.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.0.2-bin-cdh4.tgz
      fi
      ;;
    1.1.0)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.1.0-bin-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.1.0-bin-cdh4.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.1.0-bin-hadoop2.4.tgz
      fi
      ;;
    1.1.1)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.1.1-bin-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.1.1-bin-cdh4.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.1.1-bin-hadoop2.4.tgz
      fi
      ;;
    1.2.0)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.2.0-bin-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.2.0-bin-cdh4.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.2.0-bin-hadoop2.4.tgz
      fi
      ;;
    1.2.1)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.2.1-bin-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.2.1-bin-cdh4.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-1.2.1-bin-hadoop2.4.tgz
      fi
      ;;
    *)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-cdh4.tgz
      else
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop2.7.tgz
      fi
      if [ $? != 0 ]; then
        echo "ERROR: Unknown Spark version"
        return -1
      fi
  esac

  echo "Unpacking Spark"
  tar xvzf spark-*.tgz > /tmp/spark-ec2_spark.log
  rm spark-*.tgz
  mv `ls -d spark-* | grep -v ec2` spark
fi

popd > /dev/null
