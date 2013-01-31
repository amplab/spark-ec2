#!/bin/bash

cp -r /root/ephemeral-hdfs /root/persistent-hdfs

/root/spark-ec2/copy-dir /root/persistent-hdfs
