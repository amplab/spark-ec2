#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""A script for deploying Spark images to multiple EC2 datacenters.

Note: this requires boto 2.9.2 or later: `pip install boto`.
"""

from __future__ import with_statement

import logging
import sys
from optparse import OptionParser
import os
from sys import stderr
from boto.ec2.connection import EC2Connection
from boto import ec2

DEST_REGIONS = ["us-west-1", "us-west-1", "eu-west-1", "ap-southeast-1",
                "ap-southeast-2", "ap-northeast-1", "sa-east-1"]

def parse_args():
  parser = OptionParser(
      usage="image-copy <source-region> <source-image-id> <image-name>",
      add_help_option=False)
  parser.add_option("-h", "--help", action="help",
                    help="Show this help message and exit")
  (opts, args) = parser.parse_args()
  if len(args) != 3:
    parser.print_help()
    sys.exit(1)
  (source_region, source_image_id, image_name) = args
  
  # Boto config check
  # http://boto.cloudhackers.com/en/latest/boto_config_tut.html
  home_dir = os.getenv('HOME')
  if home_dir == None or not os.path.isfile(home_dir + '/.boto'):
    if not os.path.isfile('/etc/boto.cfg'):
      if os.getenv('AWS_ACCESS_KEY_ID') == None:
        print >> stderr, ("ERROR: The environment variable AWS_ACCESS_KEY_ID " +
                          "must be set")
        sys.exit(1)
      if os.getenv('AWS_SECRET_ACCESS_KEY') == None:
        print >> stderr, ("ERROR: The environment variable " +
                          "AWS_SECRET_ACCESS_KEY must be set")
        sys.exit(1)
  return (opts, source_region, source_image_id, image_name)
  
def main():
  (opts, source_region, source_image_id, image_name) = parse_args()
  dest_regions = ["us-west-1"]
  for dest_region in DEST_REGIONS:
    try:
      region = ec2.get_region(dest_region)
      conn = EC2Connection(region=region, validate_certs=False)
    except Exception as e:
      print >> stderr, (e)
      sys.exit(1)
    new_image = conn.copy_image(source_region, source_image_id, image_name)
    print "Created new image: %s in %s" % (new_image.image_id, dest_region)

if __name__ == "__main__":
  logging.basicConfig()
  main()
