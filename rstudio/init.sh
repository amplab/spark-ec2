#!/usr/bin/env bash

# download rstudio 
wget http://download2.rstudio.org/rstudio-server-rhel-0.99.446-x86_64.rpm
sudo yum install --nogpgcheck -y rstudio-server-rhel-0.99.446-x86_64.rpm

# restart rstudio 
rstudio-server restart 

# add user for rstudio, user needs to supply password later on
adduser rstudio

# create a Rscript that connects to Spark, to help starting user
cp /root/spark-ec2/rstudio/startSpark.R /home/rstudio

# make sure that the temp dirs exist and can be written to by any user
# otherwise this will create a conflict for the rstudio user
function create_temp_dirs {
  location=$1
  if [[ ! -e $location ]]; then
    mkdir -p $location
  fi
  chmod a+w $location
}

create_temp_dirs /mnt/spark
create_temp_dirs /mnt2/spark
create_temp_dirs /mnt3/spark
create_temp_dirs /mnt4/spark
