

USER=`whoami`

#learn the linux distribution
DISTRIB_ID=Centos
if [[ -e /etc/lsb-release ]]; then source /etc/lsb-release; fi
echo "DISTRIB_ID=$DISTRIB_ID"


# NOTE: Remove all rrds which might be around from an earlier run
sudo rm -rf /var/lib/ganglia/rrds/*
sudo rm -rf /mnt/ganglia/rrds/*

# Make sure rrd storage directory has right permissions
mkdir -p /mnt/ganglia/rrds
chown -R nobody:nobody /mnt/ganglia/rrds

# Install ganglia
# TODO: Remove this once the AMI has ganglia by default


if [[ $DISTRIB_ID = "Centos" ]]; then
  GANGLIA_PACKAGES="ganglia ganglia-web ganglia-gmond ganglia-gmetad"
  if ! rpm --quiet -q $GANGLIA_PACKAGES; then
    yum install -q -y $GANGLIA_PACKAGES;
  fi
  for node in $SLAVES $OTHER_MASTERS; do
    ssh -t -t $SSH_OPTS root@$node "if ! rpm --quiet -q $GANGLIA_PACKAGES; then yum install -q -y $GANGLIA_PACKAGES; fi" & sleep 0.3
  done
  wait

elif [[ $DISTRIB_ID = "Ubuntu" ]]; then
  echo "WARNING: Skipping ganglia on ubuntu..."
  #GANGLIA_PACKAGES="ganglia-webfrontend ganglia-monitor gmetad"
  #sudo apt-get install -y $GANGLIA_PACKAGES
  #for node in $SLAVES $OTHER_MASTERS; do
  #  ssh -t -t $SSH_OPTS $USER@$node "sudo apt-get install -y $GANGLIA_PACKAGES; sudo dpkg --configure -a" & sleep 0.3
  #done
  #wait
fi

# Post-package installation : Symlink /var/lib/ganglia/rrds to /mnt/ganglia/rrds
if [[ -d /var/lib/ganglia/rrds ]]; then sudo rmdir /var/lib/ganglia/rrds; fi
sudo ln -s /mnt/ganglia/rrds /var/lib/ganglia/rrds
