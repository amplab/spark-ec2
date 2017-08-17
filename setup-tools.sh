#!/bin/bash

set -e

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# Connectivity tools
echo "Install connectivity tools (ssh, rsync)"
sudo yum install -y -q pssh rsync

# Dev tools
echo "Install dev tools (gcc, ant, git)"
sudo yum install -y -q gcc gcc-c++ ant git

# Install java-8 for Spark 2.2.x
echo "Install java-8"
sudo yum install -y -q java-1.8.0 java-1.8.0-devel
sudo yum --enablerepo='*-debug*' install -y -q java-1.8.0-openjdk-debuginfo
echo "Remove java-7 and set the default to java-8"
sudo yum remove -y -q java-1.7.0
sudo /usr/sbin/alternatives --auto java
sudo /usr/sbin/alternatives --auto javac

# Perf tools
echo "Install performance tools"
sudo yum install -y -q dstat iotop strace sysstat htop perf
sudo debuginfo-install -y -q glibc
sudo debuginfo-install -y -q kernel

# PySpark and MLlib deps
echo "Install python tools"
sudo yum install -y -q python-matplotlib python-tornado scipy libgfortran
# SparkR deps
echo "Install R tools"
sudo yum install -y -q R

# Ganglia
echo "Install Ganglia monitoring tools"
sudo yum install -y -q ganglia ganglia-web ganglia-gmond ganglia-gmetad

# Install Maven
echo "Install Maven"
if [ ! -d /opt/apache-maven-3.2.3 ]; then
    cd /tmp
    wget "http://archive.apache.org/dist/maven/maven-3/3.2.3/binaries/apache-maven-3.2.3-bin.tar.gz"
    tar zxf apache-maven-3.2.3-bin.tar.gz
    mv apache-maven-3.2.3 /opt/
fi

# Edit bash profile
echo "Update .bash_profile"
if grep -q 'java-1.8.0' ~/.bash_profile; then
    echo ".bash_profile setup"
else
    echo "export PS1=\"\\u@\\h \\W]\\$ \"" >> ~/.bash_profile
    echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0" >> ~/.bash_profile
    echo "export M2_HOME=/opt/apache-maven-3.2.3" >> ~/.bash_profile
    echo "export PATH=\$PATH:\$M2_HOME/bin" >> ~/.bash_profile
fi

source ~/.bash_profile

# Create /usr/bin/realpath which is used by R to find Java installations
# NOTE: /usr/bin/realpath is missing in CentOS AMIs. See
# http://superuser.com/questions/771104/usr-bin-realpath-not-found-in-centos-6-5
if [ ! -f /usr/bin/realpath ]; then
    echo '#!/bin/bash' > /usr/bin/realpath
    echo 'readlink -e "$@"' >> /usr/bin/realpath
    chmod a+x /usr/bin/realpath
fi

