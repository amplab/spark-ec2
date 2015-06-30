# we need to add correct epel 
# http://aws.amazon.com/amazon-linux-ami/faqs/
# 
# /etc/yum.repos.d/epel.repo
# su -c 'rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm'
# yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/
# rpm -ivh https://dl.fedoraproject.org/pub/epel/6/x86_64/R-3.2.0-2.el6.x86_64.rpm
# yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/
# http://stackoverflow.com/questions/18747640/installing-r-on-rhel-6

yum update -y --enablerepo=epel --skip-broken
yum upgrade -y --enablerepo=epel --skip-broken
yum install R --enablerepo=epel --skip-broken

# download rstudio 
wget http://download2.rstudio.org/rstudio-server-rhel-0.99.446-x86_64.rpm
sudo yum install --nogpgcheck -y rstudio-server-rhel-0.99.446-x86_64.rpm

# restart rstudio 
rstudio-server restart 

# add user for rstudio 
adduser rstudio
# maybe have the user set the password themselves? 
# otherwise this might be a security issue. 
# echo 'rstudio' | passwd  --stdin rstudio