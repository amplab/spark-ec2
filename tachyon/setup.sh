#!/bin/bash

/root/spark-ec2/copy-dir /root/tachyon

/root/tachyon/bin/format.sh

sleep 1

/root/tachyon/bin/start.sh all Mount
