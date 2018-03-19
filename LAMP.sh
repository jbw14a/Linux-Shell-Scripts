#!/bin/bash

#Source that helped me --> https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-16-04

PW=Sputnik78**
MYSQL=nosrebob
IP=159.89.238.24

echo $PW | sudo apt-get -y update

#Install apache and insert server name to make error messages cleaner
echo $PW | sudo apt-get -y install apache2
echo "ServerName $IP" >> /etc/apache2/apache2.conf

echo $PW | sudo apache2ctl configtest

#Restart apache
echo $PW | sudo systemctl restart apache2

#Adjust firewall to allow web traffic

#Make sure UFW firewall is enabled
echo $PW | sudo ufw app list
echo $PW | sudo ufw app info "Apache Full"

#Allow incoming traffic for http and https
echo $PW | sudo ufw allow in "Apache Full"

#http://server_ip should have apache homepage now

#Install MySQL
echo "mysql-server mysql-server/root_password password $MYSQL" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL" | sudo debconf-set-selections
echo $PW | sudo apt-get -y install mysql-server

#Run mysql_secure_installation using expect
echo $PW | sudo apt-get -y install expect

SECURE_MYSQL_INSTALL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter password for user root:\"
send \"nosrebob\r\"
expect \"Press y|Y for Yes, any other key for No:\"
send \"n\r\"
expect \"Change the password for root ? ((Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL_INSTALL"

#Install php
echo $PW | sudo apt-get -y install php libapache2-mod-php php-mcrypt php-mysql
echo $PW | sed -i "s/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g" /etc/apache2/mods-enabled/dir.conf

#Restart apache again
echo $PW | sudo systemctl restart apache2

#Create info.php to test that php is installed properly
echo "<?php phpinfo(); ?>" > /var/www/html/info.php


#Install phpmyadmin, its extensions and enable its extensions

echo $PW | sudo echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo $PW | sudo echo "phpmyadmin phpmyadmin/app-password-confirm password $PW" | debconf-set-selections
echo $PW | sudo echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PW" | debconf-set-selections
echo $PW | sudo echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL" | debconf-set-selections
echo $PW | sudo echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo $PW | sudo apt-get -y install phpmyadmin
echo $PW | sudo apt-get -y install php-mbstring php-gettext
echo $PW | sudo phpenmod mcrypt
echo $PW | sudo phpenmod mbstring

#Make a symbolic link to the installation in your server root
echo $PW | sudo ln -s /usr/share/phpmyadmin/ /var/www/html/phpmyadmin

#Restart apache again
echo $PW | sudo systemctl restart apache2

#Install cURL for later usage
echo $PW | sudo apt-get -y install curl
