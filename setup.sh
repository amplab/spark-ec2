#!/bin/bash

# Make sure we are in the spark-ec2 directory
cd /root/spark-ec2

# Load the environment variables specific to this AMI
source /root/.bash_profile

# Load the cluster variables set by the deploy script
source ec2-variables.sh

# Set hostname based on EC2 private DNS name, so that it is set correctly
# even if the instance is restarted with a different private DNS name
PRIVATE_DNS=`wget -q -O - http://instance-data.ec2.internal/latest/meta-data/local-hostname`
PUBLIC_DNS=`wget -q -O - http://instance-data.ec2.internal/latest/meta-data/hostname`
hostname $PRIVATE_DNS
echo $PRIVATE_DNS > /etc/hostname
export HOSTNAME=$PRIVATE_DNS  # Fix the bash built-in hostname variable too

echo "Setting up Spark on `hostname`..."

# Set up the masters, slaves, etc files based on cluster env variables
echo "$MASTERS" > masters
echo "$SLAVES" > slaves

MASTERS=`cat masters`
NUM_MASTERS=`cat masters | wc -l`
OTHER_MASTERS=`cat masters | sed '1d'`
SLAVES=`cat slaves`
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"

if [[ "x$JAVA_HOME" == "x" ]] ; then
    echo "Expected JAVA_HOME to be set in .bash_profile!"
    exit 1
fi

if [[ `tty` == "not a tty" ]] ; then
    echo "Expecting a tty or pty! (use the ssh -t option)."
    exit 1
fi

echo "Setting executable permissions on scripts..."
find . -regex "^.+.\(sh\|py\)" | xargs chmod a+x

echo "Running setup-slave on master to mount filesystems, etc..."
source ./setup-slave.sh

echo "SSH'ing to master machine(s) to approve key(s)..."
for master in $MASTERS; do
  echo $master
  ssh $SSH_OPTS $master echo -n &
  sleep 0.3
done
ssh $SSH_OPTS localhost echo -n &
ssh $SSH_OPTS `hostname` echo -n &
wait

# Try to SSH to each cluster node to approve their key. Since some nodes may
# be slow in starting, we retry failed slaves up to 3 times.
TODO="$SLAVES $OTHER_MASTERS" # List of nodes to try (initially all)
TRIES="0"                          # Number of times we've tried so far
echo "SSH'ing to other cluster nodes to approve keys..."
while [ "e$TODO" != "e" ] && [ $TRIES -lt 4 ] ; do
  NEW_TODO=
  for slave in $TODO; do
    echo $slave
    ssh $SSH_OPTS $slave echo -n
    if [ $? != 0 ] ; then
        NEW_TODO="$NEW_TODO $slave"
    fi
  done
  TRIES=$[$TRIES + 1]
  if [ "e$NEW_TODO" != "e" ] && [ $TRIES -lt 4 ] ; then
      sleep 15
      TODO="$NEW_TODO"
      echo "Re-attempting SSH to cluster nodes to approve keys..."
  else
      break;
  fi
done

echo "RSYNC'ing /root/spark-ec2 to other cluster nodes..."
for node in $SLAVES $OTHER_MASTERS; do
  echo $node
  rsync -e "ssh $SSH_OPTS" -az /root/spark-ec2 $node:/root &
  scp $SSH_OPTS ~/.ssh/id_rsa $node:.ssh &
  sleep 0.3
done
wait

# NOTE: We need to rsync spark-ec2 before we can run setup-slave.sh
# on other cluster nodes
echo "Running slave setup script on other cluster nodes..."
for node in $SLAVES $OTHER_MASTERS; do
  echo $node
  ssh -t -t $SSH_OPTS root@$node "spark-ec2/setup-slave.sh" & sleep 0.3
done
wait

# Always include 'scala' module if it's not defined as a work around
# for older versions of the scripts.
if [[ ! $MODULES =~ *scala* ]]; then
  MODULES=$(printf "%s\n%s\n" "scala" $MODULES)
fi

# Install / Init module
for module in $MODULES; do
  echo "Initializing $module"
  if [[ -e $module/init.sh ]]; then
    source $module/init.sh
  fi
  cd /root/spark-ec2  # guard against init.sh changing the cwd
done

# Deploy templates
# TODO: Move configuring templates to a per-module ?
echo "Creating local config files..."
./deploy_templates.py

# Copy spark conf by default
echo "Deploying Spark config files..."
chmod u+x /root/spark/conf/spark-env.sh
/root/spark-ec2/copy-dir /root/spark/conf

# Setup each module
for module in $MODULES; do
  echo "Setting up $module"
  source ./$module/setup.sh
  sleep 1
  cd /root/spark-ec2  # guard against setup.sh changing the cwd
done
