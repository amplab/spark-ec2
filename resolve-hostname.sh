#!/bin/bash

# Starting new instance in VPC often results that `hostname` returns something like 'ip-10-1-1-24', which is
# not resolvable. Which leads to problems like SparkUI failing to bind itself on start up to that hostname as
# described in https://issues.apache.org/jira/browse/SPARK-5246.
# This script maps private ip to such hostname via '/etc/hosts'.
#

# Are we in VPC?
MAC=`wget -q -O - http://169.254.169.254/latest/meta-data/mac`
VCP_ID=`wget -q -O - http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/vpc-id`
if [ -z "${VCP_ID}" ]; then
    # echo "nothing to do - instance is not in VPC"
    exit 0
fi

SHORT_HOSTNAME=`hostname`

PRIVATE_IP=`wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4`

# do changes only if short hostname does not resolve
ping -c 1 -q "${SHORT_HOSTNAME}" > /dev/null 2>&1
if [ $? -ne 0  ]; then
    echo -e "\n# fixed by resolve-hostname.sh \n${PRIVATE_IP} ${SHORT_HOSTNAME}\n" >> /etc/hosts

    # let's make sure that it got fixed
    ping -c 1 -q "${SHORT_HOSTNAME}" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        # return some non-zero code to indicate problem
        echo "Possible bug: unable to fix resolution of local hostname"
        return 62
    fi

fi
