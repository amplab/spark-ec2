#!/bin/bash

# Install ganglia
# TODO: Remove this once the AMI has ganglia by default
yum install -q -y ganglia ganglia-gmetad ganglia-gmond ganglia-web
for node in $SLAVES $OTHER_MASTERS; do
  ssh -t -t $SSH_OPTS root@$node "yum install -q -y ganglia ganglia-gmetad ganglia-gmond ganglia-web"
done
