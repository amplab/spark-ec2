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