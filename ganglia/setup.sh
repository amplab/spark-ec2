#!/bin/bash

/root/spark-ec2/copy-dir /etc/ganglia/

# Start gmond everywhere
/etc/init.d/gmond restart

for node in $SLAVES $OTHER_MASTERS; do
  ssh -t -t $SSH_OPTS root@$node "/etc/init.d/gmond restart"
done

/etc/init.d/gmetad restart

# Start http server to serve ganglia
/etc/init.d/httpd restart
