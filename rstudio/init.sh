# download rstudio 
wget http://download2.rstudio.org/rstudio-server-rhel-0.99.446-x86_64.rpm
sudo yum install --nogpgcheck -y rstudio-server-rhel-0.99.446-x86_64.rpm

# restart rstudio 
rstudio-server restart 

# add user for rstudio 
adduser rstudio

# maybe have the user set the password themselves instead of this? 
# otherwise this might be a security issue. 
echo 'rstudio' | passwd  --stdin rstudio

sudo chmod a+w /mnt/spark
sudo chmod a+w /mnt/spark2

# create a Rscript that connects to Spark, to help starting user
echo "cat('Now connecting to Spark for you.') 
 
	spark_link <- system('cat /root/spark-ec2/cluster-url', intern=TRUE)
 
	.libPaths(c(.libPaths(), '/root/spark/R/lib')) 
	Sys.setenv(SPARK_HOME = '/root/spark') 
	Sys.setenv(PATH = paste(Sys.getenv(c('PATH')), '/root/spark/bin', sep=':')) 
	library(SparkR) 
 
	sc <- sparkR.init(spark_link) 
	sqlContext <- sparkRSQL.init(sc) 

	cat('Spark Context available as \"sc\". \\n')
	cat('Spark SQL Context available as \"sqlContext\". \\n')
"  > /home/rstudio/startSpark.R