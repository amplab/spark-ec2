#!/bin/bash

echo "$MESOS_ZOO_LIST" > zoo
ZOOS=`cat zoo`

if [[ $ZOOS = *NONE* ]]; then
  NUM_ZOOS=0
  ZOOS=""
else
  NUM_ZOOS=`cat zoo | wc -l`
fi

if [[ $NUM_ZOOS != 0 ]] ; then
  echo "SSH'ing to ZooKeeper server(s) to approve keys..."
  zid=1
  for zoo in $ZOOS; do
    echo $zoo
    ssh $SSH_OPTS $zoo echo -n \; mkdir -p /tmp/zookeeper \; echo $zid \> /tmp/zookeeper/myid &
    zid=$(($zid+1))
    sleep 0.3
  done
fi

mkdir -p /mnt/mesos-logs
mkdir -p /mnt/mesos-work

for node in $SLAVES $OTHER_MASTERS; do
  ssh -t $SSH_OPTS root@$node "mkdir -p /mnt/mesos-logs /mnt/mesos-work" & sleep 0.3
done
wait

DOWNLOADED=0

if [[ "$MESOS_DOWNLOAD_METHOD" == "git" ]] ; then
  # change git's ssh command so it does not ask to accept a keys
  export GIT_SSH=/root/spark-ec2/ssh-no-keychecking.sh
  REPOSITORY=git://github.com/apache/mesos.git
  echo "Checking out Mesos from $REPOSITORY"
  pushd /root > /dev/null 2>&1
  rm -rf mesos mesos.tgz
  # Set git SSH command to a script that uses -o StrictHostKeyChecking=no
  git clone $REPOSITORY mesos
  pushd mesos 2>&1
  git checkout -b $BRANCH --track origin/$BRANCH
  popd > /dev/null 2>&1
  popd > /dev/null 2>&1
  DOWNLOADED=1
fi

# Build Mesos if we downloaded it
if [[ "$DOWNLOADED" == "1" ]] ; then
  echo "Building Mesos..."
  mkdir /root/mesos/build
  pushd /root/mesos/build > /dev/null 2>&1
  ./configure.amazon-linux-64
  make clean
  make
  popd > /dev/null 2>&1
  if [ -d /root/spark ] ; then
    echo "Building Spark..."
    pushd /root/spark > /dev/null 2>&1
    git pull
    sbt/sbt clean compile
    popd > /dev/null 2>&1
  fi
  echo "Building Hadoop framework..."
  pushd /root/mesos/build > /dev/null 2>&1
  make hadoop
  rm -fr /root/hadoop-mesos
  mv /root/mesos/build/hadoop/hadoop-0.20.205.0 /root/hadoop-mesos
  popd > /dev/null 2>&1
fi

echo "Setting up Hadoop framework config files..."
cp /root/spark-ec2/mesos/hadoop-framework-conf/* /root/hadoop-mesos/conf

echo "Deploying Hadoop framework config files..."
/root/spark-ec2/copy-dir /root/hadoop-mesos/conf

echo "Redeploying /root/mesos..."
/root/spark-ec2/mesos/redeploy-mesos

if [[ $NUM_ZOOS != 0 ]]; then
  echo "Starting ZooKeeper quorum..."
  for zoo in $ZOOS; do
    ssh $SSH_OPTS $zoo "/root/mesos/third_party/zookeeper-*/bin/zkServer.sh start </dev/null >/dev/null" & sleep 0.1
  done
  wait
  sleep 5
fi

echo "Stopping any existing Mesos cluster..."
/root/spark-ec2/mesos/stop-mesos
sleep 2

echo "Starting Mesos cluster..."
/root/spark-ec2/mesos/start-mesos
