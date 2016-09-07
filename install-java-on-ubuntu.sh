#!/bin/bash

if [[ "x$JAVA_HOME" == "x" ]]; then
  #also install java on the first master since stock ubuntu ami does not
  #come with java pre-installed; also install git
  sudo apt-get update -q
  sudo apt-get install -y -q openjdk-7-jdk
  sudo sh -c 'echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> /etc/environment'
  source /etc/environment
fi
