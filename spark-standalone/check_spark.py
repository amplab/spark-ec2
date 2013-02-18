#!/usr/bin/env python
# -*- coding: utf-8 -*-

from optparse import OptionParser

import json
import sys
import urllib2

def main():
  parser = OptionParser(usage="check_spark [spark_master_hostname] [num_workers]",
      add_help_option=True)
  (opts, args) = parser.parse_args()
  if len(args) != 2:
    parser.print_help()
    sys.exit(1)
  else:
    status = check_spark_master(args[0], args[1])
    sys.exit(status)

def check_spark_master(master_hostname, num_workers):
  master_url = "http://" + master_hostname + ":8080"
  url = master_url + "?format=json"
  response = urllib2.urlopen(url, timeout=30)
  if response.code != 200:
    print("Spark master " + url + " returned " + str(response.code))
    return 1
  master_json = response.read()
  return check_spark_json(master_json, num_workers)

def check_spark_json(spark_json, num_workers):
  json_data = json.loads(spark_json)
  ## Find number of workers from status page
  got_workers = len(json_data.get("workers"))
  if got_workers == int(num_workers):
    return 0
  else:
    return 1 

if __name__ == "__main__":
  main()
