#!/bin/bash

/root/spark-ec2/copy-dir /etc/ganglia/

for node in $NEW_SLAVES; do
  ssh -t -t $SSH_OPTS root@$node "/etc/init.d/gmond restart"
done
