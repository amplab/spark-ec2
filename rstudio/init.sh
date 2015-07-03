# we need to add correct epel 
# http://stackoverflow.com/questions/31180061/r-3-2-on-aws-ami
# yum update -y --enablerepo=epel --skip-broken
# yum upgrade -y --enablerepo=epel --skip-broken
# yum install R --enablerepo=epel --skip-broken

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

# create an .Rprofile that automatically connects to Spark 
echo ".First <- function(){ 
	cat('Now connecting to Spark for you.') 
	region_ip <- system('curl http://169.254.169.254/latest/meta-data/public-hostname', intern=TRUE) 
 
	spark_link <- paste0('spark://', region_ip, ':7077') 
 
	.libPaths(c(.libPaths(), '/root/spark/R/lib')) 
	Sys.setenv(SPARK_HOME = '/root/spark') 
	Sys.setenv(PATH = paste(Sys.getenv(c('PATH')), '/root/spark/bin', sep=':')) 
	library(SparkR) 
 
	sc <- sparkR.init(spark_link) 
	sqlContext <- sparkRSQL.init(sc) 

	cat('      ____              __ \\n')
	cat('     / __/__  ___ _____/ /__ \\n')
	cat('    _\\\\ \\\\/ _ \\\\/ _ \`/ __/   _/ \\n')
	cat('   /__ / .__/\\\\_,_/_/ /_/\\\\_\\   version 1.4.0 \\n')
	cat('      /_/ \\n')
	cat(' \\n')
	cat('Spark Context available as \"sc\". \\n')
	cat('Spark SQL Context available as \"sqlContext\". \\n')
}"  > /root/.Rprofile 