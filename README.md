# EC2 Cluster Setup for Apache Spark

`spark-ec2` allows you
to launch, manage and shut down
[Apache Spark](http://spark.apache.org/docs/latest/ec2-scripts.html) [1] clusters
on Amazon EC2. It automatically sets up Apache Spark and
[HDFS](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html)
on the cluster for you. This guide describes
how to use `spark-ec2` to launch clusters, how to run jobs on them, and how 
to shut them down. It assumes you've already signed up for an EC2 account 
on the [Amazon Web Services site](http://aws.amazon.com/).

`spark-ec2` is designed to manage multiple named clusters. You can
launch a new cluster (telling the script its size and giving it a name),
shutdown an existing cluster, or log into a cluster. Each cluster is
identified by placing its machines into EC2 security groups whose names
are derived from the name of the cluster. For example, a cluster named
`test` will contain a master node in a security group called
`test-master`, and a number of slave nodes in a security group called
`test-slaves`. The `spark-ec2` script will create these security groups
for you based on the cluster name you request. You can also use them to
identify machines belonging to each cluster in the Amazon EC2 Console.

[1] Apache, [Apache Spark](http://spark.apache.org), and Spark are trademarks of the Apache Software Foundation.

## Before You Start

-   Create an Amazon EC2 key pair for yourself. This can be done by
    logging into your Amazon Web Services account through the [AWS
    console](http://aws.amazon.com/console/), clicking Key Pairs on the
    left sidebar, and creating and downloading a key. Make sure that you
    set the permissions for the private key file to `600` (i.e. only you
    can read and write it) so that `ssh` will work.
-   Whenever you want to use the `spark-ec2` script, set the environment
    variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your
    Amazon EC2 access key ID and secret access key. These can be
    obtained from the [AWS homepage](http://aws.amazon.com/) by clicking
    Account > Security Credentials > Access Credentials.

## Launching a Cluster

-   Go into the `ec2` directory in the release of Apache Spark you downloaded.
-   Run
    `./spark-ec2 -k <keypair> -i <key-file> -s <num-slaves> launch <cluster-name>`,
    where `<keypair>` is the name of your EC2 key pair (that you gave it
    when you created it), `<key-file>` is the private key file for your
    key pair, `<num-slaves>` is the number of slave nodes to launch (try
    1 at first), and `<cluster-name>` is the name to give to your
    cluster.

    For example:

    ```bash
    export AWS_SECRET_ACCESS_KEY=AaBbCcDdEeFGgHhIiJjKkLlMmNnOoPpQqRrSsTtU
export AWS_ACCESS_KEY_ID=ABCDEFG1234567890123
./spark-ec2 --key-pair=awskey --identity-file=awskey.pem --region=us-west-1 --zone=us-west-1a launch my-spark-cluster
    ```

-   After everything launches, check that the cluster scheduler is up and sees
    all the slaves by going to its web UI, which will be printed at the end of
    the script (typically `http://<master-hostname>:8080`).

You can also run `./spark-ec2 --help` to see more usage options. The
following options are worth pointing out:

-   `--instance-type=<instance-type>` can be used to specify an EC2
instance type to use. For now, the script only supports 64-bit instance
types, and the default type is `m1.large` (which has 2 cores and 7.5 GB
RAM). Refer to the Amazon pages about [EC2 instance
types](http://aws.amazon.com/ec2/instance-types) and [EC2
pricing](http://aws.amazon.com/ec2/#pricing) for information about other
instance types. 
-    `--region=<ec2-region>` specifies an EC2 region in which to launch
instances. The default region is `us-east-1`.
-    `--zone=<ec2-zone>` can be used to specify an EC2 availability zone
to launch instances in. Sometimes, you will get an error because there
is not enough capacity in one zone, and you should try to launch in
another.
-    `--ebs-vol-size=<GB>` will attach an EBS volume with a given amount
     of space to each node so that you can have a persistent HDFS cluster
     on your nodes across cluster restarts (see below).
-    `--spot-price=<price>` will launch the worker nodes as
     [Spot Instances](http://aws.amazon.com/ec2/spot-instances/),
     bidding for the given maximum price (in dollars).
-    `--spark-version=<version>` will pre-load the cluster with the
     specified version of Spark. The `<version>` can be a version number
     (e.g. "0.7.3") or a specific git hash. By default, a recent
     version will be used.
-    `--spark-git-repo=<repository url>` will let you run a custom version of
     Spark that is built from the given git repository. By default, the
     [Apache Github mirror](https://github.com/apache/spark) will be used.
     When using a custom Spark version, `--spark-version` must be set to git
     commit hash, such as 317e114, instead of a version number.
-    If one of your launches fails due to e.g. not having the right
permissions on your private key file, you can run `launch` with the
`--resume` option to restart the setup process on an existing cluster.

## Launching a Cluster in a VPC

-   Run
    `./spark-ec2 -k <keypair> -i <key-file> -s <num-slaves> --vpc-id=<vpc-id> --subnet-id=<subnet-id> launch <cluster-name>`,
    where `<keypair>` is the name of your EC2 key pair (that you gave it
    when you created it), `<key-file>` is the private key file for your
    key pair, `<num-slaves>` is the number of slave nodes to launch (try
    1 at first), `<vpc-id>` is the name of your VPC, `<subnet-id>` is the
    name of your subnet, and `<cluster-name>` is the name to give to your
    cluster.

    For example:

    ```bash
    export AWS_SECRET_ACCESS_KEY=AaBbCcDdEeFGgHhIiJjKkLlMmNnOoPpQqRrSsTtU
export AWS_ACCESS_KEY_ID=ABCDEFG1234567890123
./spark-ec2 --key-pair=awskey --identity-file=awskey.pem --region=us-west-1 --zone=us-west-1a --vpc-id=vpc-a28d24c7 --subnet-id=subnet-4eb27b39 --spark-version=1.1.0 launch my-spark-cluster
    ```

## Running Applications

-   Go into the `ec2` directory in the release of Spark you downloaded.
-   Run `./spark-ec2 -k <keypair> -i <key-file> login <cluster-name>` to
    SSH into the cluster, where `<keypair>` and `<key-file>` are as
    above. (This is just for convenience; you could also use
    the EC2 console.)
-   To deploy code or data within your cluster, you can log in and use the
    provided script `~/spark-ec2/copy-dir`, which,
    given a directory path, RSYNCs it to the same location on all the slaves.
-   If your application needs to access large datasets, the fastest way to do
    that is to load them from Amazon S3 or an Amazon EBS device into an
    instance of the Hadoop Distributed File System (HDFS) on your nodes.
    The `spark-ec2` script already sets up a HDFS instance for you. It's
    installed in `/root/ephemeral-hdfs`, and can be accessed using the
    `bin/hadoop` script in that directory. Note that the data in this
    HDFS goes away when you stop and restart a machine.
-   There is also a *persistent HDFS* instance in
    `/root/persistent-hdfs` that will keep data across cluster restarts.
    Typically each node has relatively little space of persistent data
    (about 3 GB), but you can use the `--ebs-vol-size` option to
    `spark-ec2` to attach a persistent EBS volume to each node for
    storing the persistent HDFS.
-   Finally, if you get errors while running your application, look at the slave's logs
    for that application inside of the scheduler work directory (/root/spark/work). You can
    also view the status of the cluster using the web UI: `http://<master-hostname>:8080`.

## Configuration

You can edit `/root/spark/conf/spark-env.sh` on each machine to set Spark configuration options, such
as JVM options. This file needs to be copied to **every machine** to reflect the change. The easiest way to
do this is to use a script we provide called `copy-dir`. First edit your `spark-env.sh` file on the master, 
then run `~/spark-ec2/copy-dir /root/spark/conf` to RSYNC it to all the workers.

The [configuration guide](configuration.html) describes the available configuration options.

## Terminating a Cluster

***Note that there is no way to recover data on EC2 nodes after shutting
them down! Make sure you have copied everything important off the nodes
before stopping them.***

-   Go into the `ec2` directory in the release of Spark you downloaded.
-   Run `./spark-ec2 destroy <cluster-name>`.

## Pausing and Restarting Clusters

The `spark-ec2` script also supports pausing a cluster. In this case,
the VMs are stopped but not terminated, so they
***lose all data on ephemeral disks*** but keep the data in their
root partitions and their `persistent-hdfs`. Stopped machines will not
cost you any EC2 cycles, but ***will*** continue to cost money for EBS
storage.

- To stop one of your clusters, go into the `ec2` directory and run
`./spark-ec2 --region=<ec2-region> stop <cluster-name>`.
- To restart it later, run
`./spark-ec2 -i <key-file> --region=<ec2-region> start <cluster-name>`.
- To ultimately destroy the cluster and stop consuming EBS space, run
`./spark-ec2 --region=<ec2-region> destroy <cluster-name>` as described in the previous
section.

## Limitations

- Support for "cluster compute" nodes is limited -- there's no way to specify a
  locality group. However, you can launch slave nodes in your
  `<clusterName>-slaves` group manually and then use `spark-ec2 launch
  --resume` to start a cluster with them.

If you have a patch or suggestion for one of these limitations, feel free to
[contribute](contributing-to-spark.html) it!

## Accessing Data in S3

Spark's file interface allows it to process data in Amazon S3 using the same URI formats that are supported for Hadoop. You can specify a path in S3 as input through a URI of the form `s3n://<bucket>/path`. To provide AWS credentials for S3 access, launch the Spark cluster with the option `--copy-aws-credentials`. Full instructions on S3 access using the Hadoop input libraries can be found on the [Hadoop S3 page](http://wiki.apache.org/hadoop/AmazonS3).

In addition to using a single input file, you can also use a directory of files as input by simply giving the path to the directory.

This repository contains the set of scripts used to setup a Spark cluster on
EC2. These scripts are intended to be used by the default Spark AMI and is *not*
expected to work on other AMIs. If you wish to start a cluster using Spark,
please refer to http://spark-project.org/docs/latest/ec2-scripts.html 

## spark-ec2 Internals

The Spark cluster setup is guided by the values set in `ec2-variables.sh`.`setup.sh`
first performs basic operations like enabling ssh across machines, mounting ephemeral
drives and also creates files named `/root/spark-ec2/masters`, and `/root/spark-ec2/slaves`.
Following that every module listed in `MODULES` is initialized. 

To add a new module, you will need to do the following:

1. Create a directory with the module's name.

2. Optionally add a file named `init.sh`. This is called before templates are configured 
and can be used to install any pre-requisites.

3. Add any files that need to be configured based on the cluster setup to `templates/`.
The path of the file determines where the configured file will be copied to. Right now
the set of variables that can be used in a template are:

    ```
    {{master_list}}
    {{active_master}}
    {{slave_list}}
    {{zoo_list}}
    {{cluster_url}}
    {{hdfs_data_dirs}}
    {{mapred_local_dirs}}
    {{spark_local_dirs}}
    {{spark_worker_mem}}
    {{spark_worker_instances}}
    {{spark_worker_cores}}
    {{spark_master_opts}}
    ```

  You can add new variables by modifying `deploy_templates.py`.

4. Add a file named `setup.sh` to launch any services on the master/slaves. This is called
after the templates have been configured. You can use the environment variables `$SLAVES` to
get a list of slave hostnames and `/root/spark-ec2/copy-dir` to sync a directory across machines.

5. Modify `spark_ec2.py` to add your module to the list of enabled modules.
