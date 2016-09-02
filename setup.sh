#!/bin/bash

#learn the current user
USER=`whoami`

#learn the linux distribution
DISTRIB_ID=Centos
if [[ -e /etc/lsb-release ]]; then source /etc/lsb-release; fi
echo "DISTRIB_ID=$DISTRIB_ID"

if [[ $DISTRIB_ID = "Centos" ]]; then
  sudo yum install -y -q pssh
elif [[ $DISTRIB_ID = "Ubuntu" ]]; then
  sudo apt-get install -y pssh
fi

# usage: echo_time_diff name start_time end_time
echo_time_diff () {
  local format='%Hh %Mm %Ss'

  local diff_secs="$(($3-$2))"
  echo "[timing] $1: " "$(date -u -d@"$diff_secs" +"$format")"
}

# Make sure we are in the spark-ec2 directory
pushd ~/spark-ec2 > /dev/null

# Load the environment variables specific to this AMI
if [[ -e ~/.bash_profile ]]; then source ~/.bash_profile; fi

# Load the cluster variables set by the deploy script
source ec2-variables.sh 
# Set hostname based on EC2 private DNS name, so that it is set correctly
# even if the instance is restarted with a different private DNS name
PRIVATE_DNS=`wget -q -O - http://169.254.169.254/latest/meta-data/local-hostname`
PUBLIC_DNS=`wget -q -O - http://169.254.169.254/latest/meta-data/hostname`
sudo hostname $PRIVATE_DNS
sudo chmod o+w /etc/hostname
sudo echo $PRIVATE_DNS > /etc/hostname
sudo chmod o-w /etc/hostname
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

echo "RSYNC'ing ~/spark-ec2 to other cluster nodes..."
rsync_start_time="$(date +'%s')"
for node in $SLAVES $OTHER_MASTERS; do
  echo $node
  rsync -e "ssh $SSH_OPTS" -az ~/spark-ec2 $node:~ &
  scp $SSH_OPTS ~/.ssh/id_rsa $node:.ssh &
  sleep 0.1
done
wait
rsync_end_time="$(date +'%s')"
echo_time_diff "rsync ~/spark-ec2" "$rsync_start_time" "$rsync_end_time"

create_ephemeral_blkdev_links() {
  device_letter=$1
  devx=/dev/xvd${device_letter}
  devs=/dev/sd${device_letter}
  if [[ -e $devx ]]; then sudo ln -s $devx $devs; fi
}
if [[ $DISTRIB_ID = "Ubuntu" ]]; then
  create_ephemeral_blkdev_links b
  create_ephemeral_blkdev_links c
  create_ephemeral_blkdev_links d
fi

exit

echo "Running setup-slave on all cluster nodes to mount filesystems, etc..."
setup_slave_start_time="$(date +'%s')"
if [[ $DISTRIB_ID = "Centos" ]]; then
  pssh --inline \
    --host "$MASTERS $SLAVES" \
    --user $USER \
    --extra-args "-t -t $SSH_OPTS" \
    --timeout 0 \
    "spark-ec2/setup-slave.sh"
elif [[ $DISTRIB_ID = "Ubuntu" ]]; then
  mkdir slave-setup-stdout
  mkdir slave-setup-stderr
  parallel-ssh --inline \
    --host "$MASTERS $SLAVES" \
    --user $USER \
    --extra-args "-t -t $SSH_OPTS" \
    --timeout 0 \
    --outdir slave-setup-stdout \
    --errdir slave-setup-stderr \
    "spark-ec2/setup-slave.sh"
fi

setup_slave_end_time="$(date +'%s')"
echo_time_diff "setup-slave" "$setup_slave_start_time" "$setup_slave_end_time"

exit

# Always include 'scala' module if it's not defined as a work around
# for older versions of the scripts.
if [[ ! $MODULES =~ *scala* ]]; then
  MODULES=$(printf "%s\n%s\n" "scala" $MODULES)
fi

# Install / Init module
for module in $MODULES; do
  echo "Initializing $module"
  module_init_start_time="$(date +'%s')"
  if [[ -e $module/init.sh ]]; then
    source $module/init.sh
  fi
  module_init_end_time="$(date +'%s')"
  echo_time_diff "$module init" "$module_init_start_time" "$module_init_end_time"
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
  module_setup_start_time="$(date +'%s')"
  source ./$module/setup.sh
  sleep 0.1
  module_setup_end_time="$(date +'%s')"
  echo_time_diff "$module setup" "$module_setup_start_time" "$module_setup_end_time"
  cd /root/spark-ec2  # guard against setup.sh changing the cwd
done

popd > /dev/null
