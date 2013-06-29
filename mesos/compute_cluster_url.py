#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

# Get the Mesos cluster URL, assuming the EC2 script environment variables
# are all available.

active_master = os.getenv("MESOS_MASTERS").split("\n")[0]
zoo_list = os.getenv("MESOS_ZOO_LIST")

if zoo_list.strip() == "NONE":
  print "mesos://" + active_master + ":5050"
else:
  zoo_nodes = zoo_list.trim().split("\n")
  print "zoo://" + ",".join(["%s:2181/mesos" % node for node in zoo_nodes])
