#!/bin/bash

sudo yum install -y -q git python dstat strace java-1.6.0-openjdk-devel ant

sudo sed -i 's/PermitRootLogin.*/PermitRootLogin without-password/g' /etc/ssh/sshd_config
sudo cp /home/ec2-user/.ssh/authorized_keys /root/.ssh/
sudo /etc/init.d/sshd restart
