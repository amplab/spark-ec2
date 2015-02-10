spark-ec2
=========

This repository contains the set of scripts used to setup a Spark cluster on
EC2. These scripts are intended to be used by the default Spark AMI and is *not*
expected to work on other AMIs. If you wish to start a cluster using Spark,
please refer to http://spark-project.org/docs/latest/ec2-scripts.html 

### Details


The Spark cluster setup is guided by the values set in `ec2-variables.sh`.`setup.sh`
first performs basic operations like enabling ssh across machines, mounting ephemeral
drives and also creates files named `/root/spark-ec2/masters`, and `/root/spark-ec2/slaves`.
Following that every module listed in `MODULES` is initialized. 

To add a new module, you will need to do the following:

  a. Create a directory with the module's name
  
  b. Optionally add a file named `init.sh`. This is called before templates are configured 
and can be used to install any pre-requisites.

  c. Add any files that need to be configured based on the cluster setup to `templates/`.
  The path of the file determines where the configured file will be copied to. Right now
  the set of variables that can be used in a template are
  
      {{master_list}}
      {{active_master}}
      {{slave_list}}
      {{zoo_list}}
      {{cluster_url}}
      {{hdfs_data_dirs}}
      {{mapred_local_dirs}}
      {{spark_local_dirs}}
      {{default_spark_mem}}
      {{spark_worker_instances}}
      {{spark_worker_cores}}
      {{spark_master_opts}}
      
   You can add new variables by modifying `deploy_templates.py`
   
   d. Add a file named `setup.sh` to launch any services on the master/slaves. This is called
   after the templates have been configured. You can use the environment variables `$SLAVES` to
   get a list of slave hostnames and `/root/spark-ec2/copy-dir` to sync a directory across machines.
      
   e. Modify https://github.com/mesos/spark/blob/master/ec2/spark_ec2.py to add your module to
   the list of enabled modules.
