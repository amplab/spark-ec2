#!/bin/bash

sudo yum install -y pssh

# Make sure we are in the spark-ec2 directory
pushd /root/spark-ec2

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

echo "RSYNC'ing /root/spark-ec2 to other cluster nodes..."
for node in $SLAVES $OTHER_MASTERS; do
  echo $node
  rsync -e "ssh $SSH_OPTS" -az /root/spark-ec2 $node:/root &
  scp $SSH_OPTS ~/.ssh/id_rsa $node:.ssh &
  sleep 0.1
done
wait

echo "Running setup-slave on all cluster nodes to mount filesystems, etc..."
pssh --inline \
    --host "$MASTERS $SLAVES" \
    --user root \
    --extra-args "-t -t $SSH_OPTS" \
    "spark-ec2/setup-slave.sh"

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
  sleep 0.1
  cd /root/spark-ec2  # guard against setup.sh changing the cwd
done

popd
