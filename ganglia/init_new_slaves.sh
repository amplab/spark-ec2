#!/bin/bash

# Install ganglia on new slaves
# TODO: Remove this once the AMI has ganglia by default

for node in $NEW_SLAVES; do
  ssh -t -t $SSH_OPTS root@$node "if ! rpm --quiet -q $GANGLIA_PACKAGES; then yum install -q -y $GANGLIA_PACKAGES; fi" & sleep 0.3
done
wait
