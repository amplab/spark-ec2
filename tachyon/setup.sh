#!/bin/bash

~/spark-ec2/copy-dir ~/tachyon

~/tachyon/bin/tachyon format

sleep 1

~/tachyon/bin/tachyon-start.sh all Mount
