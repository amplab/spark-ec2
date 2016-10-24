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
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-prebuilt-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-prebuilt-cdh4.tgz
      else
       echo "ERROR: Unsupported Hadoop major version"
       return 1
      fi
    ;;
    0\.8\.0|0\.8\.1|0\.9\.0)
     if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-incubating-bin-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-incubating-bin-cdh4.tgz
      else
       echo "ERROR: Unsupported Hadoop major version"
       return 1
      fi
    ;;
    # 0.9.1 - 1.0.2
    0.9.1|1\.0\.[0-2])
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-cdh4.tgz
      else
       echo "ERROR: Unsupported Hadoop major version"
       return 1
      fi
    ;;
    # 1.1.0 - 1.3.0
    1\.[1-2]\.[0-9]*|1\.3\.0)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-cdh4.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "yarn" ]]; then
        if [[ "$HADOOP_MINOR_VERSION" == "2.4" ]]; then
          wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop2.4.tgz
        else
          echo "ERROR: Unknown Hadoop minor version"
          return 1
        fi
      else
       echo "ERROR: Unsupported Hadoop major version"
       return 1
      fi
    ;;
    # 1.3.1 - 1.6.2
    1\.[3-6]\.[0-2])
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop1.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-cdh4.tgz
      elif [[ "$HADOOP_MAJOR_VERSION" == "yarn" ]]; then
        if [[ "$HADOOP_MINOR_VERSION" == "2.4" ]]; then
          wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop2.4.tgz
        elif [[ "$HADOOP_MINOR_VERSION" == "2.6" ]]; then
          wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop2.6.tgz
        else
          echo "ERROR: Unknown Hadoop minor version"
          return 1
        fi
      else
        echo "ERROR: Unsupported Hadoop major version"
        return 1
      fi
    ;;
    # 2.0.0 - 2.0.1
    2\.0\.[0-1]|2\.0\.0-preview)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        echo "ERROR: Unknown Hadoop major version"
        return 1
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        echo "ERROR: Unknown Hadoop major version"
        return 1
      elif [[ "$HADOOP_MAJOR_VERSION" == "yarn" ]]; then
        if [[ "$HADOOP_MINOR_VERSION" == "2.4" ]]; then
          wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop2.4.tgz
        elif [[ "$HADOOP_MINOR_VERSION" == "2.6" ]]; then
          wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop2.6.tgz
        elif [[ "$HADOOP_MINOR_VERSION" == "2.7" ]]; then
          wget http://s3.amazonaws.com/spark-related-packages/spark-$SPARK_VERSION-bin-hadoop2.7.tgz
        else
          echo "ERROR: Unknown Hadoop version"
          return 1
        fi
      else
        echo "ERROR: Unsupported Hadoop major version"
        return 1
      fi
    ;;
    *)
      if [ $? != 0 ]; then
        echo "ERROR: Unknown Spark version"
        return 1
      fi
    ;;
 esac

  echo "Unpacking Spark"
  tar xvzf spark-*.tgz > /tmp/spark-ec2_spark.log
  rm spark-*.tgz
  mv `ls -d spark-* | grep -v ec2` spark
fi

popd > /dev/null
