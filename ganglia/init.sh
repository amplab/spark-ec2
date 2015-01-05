#!/bin/bash

# NOTE: Remove all rrds which might be around from an earlier run
rm -rf /var/lib/ganglia/rrds/*
rm -rf /mnt/ganglia/rrds/*

# Make sure rrd storage directory has right permissions
mkdir -p /mnt/ganglia/rrds
chown -R nobody:nobody /mnt/ganglia/rrds

# Install ganglia
# TODO: Remove this once the AMI has ganglia by default

GANGLIA_PACKAGES="ganglia ganglia-web ganglia-gmond ganglia-gmetad"

if ! rpm --quiet -q $GANGLIA_PACKAGES; then
  yum install -q -y $GANGLIA_PACKAGES;
fi
for node in $SLAVES $OTHER_MASTERS; do
  ssh -t -t $SSH_OPTS root@$node "if ! rpm --quiet -q $GANGLIA_PACKAGES; then yum install -q -y $GANGLIA_PACKAGES; fi" & sleep 0.3
done
wait

# Post-package installation : Symlink /var/lib/ganglia/rrds to /mnt/ganglia/rrds
rmdir /var/lib/ganglia/rrds
ln -s /mnt/ganglia/rrds /var/lib/ganglia/rrds
