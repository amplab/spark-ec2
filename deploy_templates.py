#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement

import os
import sys

# Deploy the configuration file templates in the spark-ec2/templates directory
# to the root filesystem, substituting variables such as the master hostname,
# ZooKeeper URL, etc as read from the environment.

# Find system memory in KB and compute Spark's default limit from that
system_ram_kb = int(
  os.popen("cat /proc/meminfo | grep MemTotal | awk '{print $2}'")
    .read().strip())
system_ram_mb = system_ram_kb / 1024
if system_ram_mb > 20*1024:
  # Leave 3 GB for the OS, HDFS and buffer cache
  spark_mb = system_ram_mb - 3 * 1024
elif system_ram_mb > 10*1024:
  # Leave 2 GB for the OS & co.
  spark_mb = system_ram_mb - 2 * 1024
else:
  # Leave 1.3 GB for the OS & co. Note that this must be more than
  # 1 GB because Mesos leaves 1 GB free and requires 32 MB/task.
  spark_mb = max(512, system_ram_mb - 1300)

template_vars = {
  "master_list": os.getenv("MASTERS"),
  "active_master": os.getenv("MASTERS").split("\n")[0],
  "slave_list": os.getenv("SLAVES"),
  "zoo_list": os.getenv("MESOS_ZOO_LIST"),
  "cluster_url": os.getenv("MESOS_CLUSTER_URL"),
  "hdfs_data_dirs": os.getenv("HDFS_DATA_DIRS"),
  "mapred_local_dirs": os.getenv("MAPRED_LOCAL_DIRS"),
  "spark_local_dirs": os.getenv("SPARK_LOCAL_DIRS"),
  "default_spark_mem": "%dm" % spark_mb
}

template_dir="/root/spark-ec2/templates"

for path, dirs, files in os.walk(template_dir):
  if path.find(".svn") == -1:
    dest_dir = os.path.join('/', path[len(template_dir):])
    if not os.path.exists(dest_dir):
      os.makedirs(dest_dir)
    for filename in files:
      if filename[0] not in '#.~' and filename[-1] != '~':
        dest_file = os.path.join(dest_dir, filename)
        with open(os.path.join(path, filename)) as src:
          with open(dest_file, "w") as dest:
            print "Configuring " + dest_file
            text = src.read()
            for key in template_vars:
              text = text.replace("{{" + key + "}}", template_vars[key])
            dest.write(text)
            dest.close()
